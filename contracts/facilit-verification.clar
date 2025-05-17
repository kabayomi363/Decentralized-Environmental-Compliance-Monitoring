;; Facility Verification Contract
;; This contract validates industrial sites and their operational status

(define-data-var administrator principal tx-sender)

;; A map of registered facilities and their verification status
(define-map facilities
  { facility-id: uint }
  {
    name: (string-ascii 100),
    owner: principal,
    location: (string-ascii 100),
    industry-type: (string-ascii 50),
    verified: bool,
    verification-date: uint
  }
)

;; Counter for facility IDs
(define-data-var facility-counter uint u0)

;; Error codes
(define-constant ERR_UNAUTHORIZED u1000)
(define-constant ERR_ALREADY_REGISTERED u1001)
(define-constant ERR_NOT_FOUND u1002)

;; Register a new facility (only by administrator)
(define-public (register-facility (name (string-ascii 100)) (owner principal) (location (string-ascii 100)) (industry-type (string-ascii 50)))
  (let ((current-admin (var-get administrator))
        (facility-id (+ (var-get facility-counter) u1)))
    (asserts! (is-eq tx-sender current-admin) (err ERR_UNAUTHORIZED))
    (var-set facility-counter facility-id)
    (ok (map-insert facilities
      { facility-id: facility-id }
      {
        name: name,
        owner: owner,
        location: location,
        industry-type: industry-type,
        verified: false,
        verification-date: u0
      }))))

;; Verify a facility (only by administrator)
(define-public (verify-facility (facility-id uint))
  (let ((current-admin (var-get administrator))
        (facility (map-get? facilities {facility-id: facility-id})))
    (asserts! (is-eq tx-sender current-admin) (err ERR_UNAUTHORIZED))
    (asserts! (is-some facility) (err ERR_NOT_FOUND))
    (ok (map-set facilities
      { facility-id: facility-id }
      (merge (unwrap-panic facility)
             { verified: true, verification-date: block-height })))))

;; Get facility details
(define-read-only (get-facility (facility-id uint))
  (map-get? facilities {facility-id: facility-id}))

;; Check if a facility is verified
(define-read-only (is-facility-verified (facility-id uint))
  (match (map-get? facilities {facility-id: facility-id})
    facility (get verified facility)
    false))

;; Transfer admin rights
(define-public (transfer-administrator (new-admin principal))
  (let ((current-admin (var-get administrator)))
    (asserts! (is-eq tx-sender current-admin) (err ERR_UNAUTHORIZED))
    (var-set administrator new-admin)
    (ok new-admin)))
