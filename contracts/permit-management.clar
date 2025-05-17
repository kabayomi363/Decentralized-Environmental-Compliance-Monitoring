;; Permit Management Contract
;; Records authorized emission levels and permit details

(define-data-var administrator principal tx-sender)

;; Permit data structure
(define-map permits
  { permit-id: uint }
  {
    facility-id: uint,
    emission-type: (string-ascii 50),
    max-level: uint,
    issue-date: uint,
    expiry-date: uint,
    issuer: principal,
    active: bool
  }
)

;; Counter for permit IDs
(define-data-var permit-counter uint u0)

;; Error codes
(define-constant ERR_UNAUTHORIZED u1000)
(define-constant ERR_NOT_FOUND u1002)
(define-constant ERR_INVALID_DATE u1003)

;; Issue a new permit (only by administrator)
(define-public (issue-permit
                (facility-id uint)
                (emission-type (string-ascii 50))
                (max-level uint)
                (expiry-date uint))
  (let ((current-admin (var-get administrator))
        (permit-id (+ (var-get permit-counter) u1)))
    (asserts! (is-eq tx-sender current-admin) (err ERR_UNAUTHORIZED))
    (asserts! (> expiry-date block-height) (err ERR_INVALID_DATE))

    (var-set permit-counter permit-id)
    (ok (map-insert permits
      { permit-id: permit-id }
      {
        facility-id: facility-id,
        emission-type: emission-type,
        max-level: max-level,
        issue-date: block-height,
        expiry-date: expiry-date,
        issuer: tx-sender,
        active: true
      }))))

;; Revoke a permit (only by administrator)
(define-public (revoke-permit (permit-id uint))
  (let ((current-admin (var-get administrator))
        (permit (map-get? permits {permit-id: permit-id})))
    (asserts! (is-eq tx-sender current-admin) (err ERR_UNAUTHORIZED))
    (asserts! (is-some permit) (err ERR_NOT_FOUND))

    (ok (map-set permits
      { permit-id: permit-id }
      (merge (unwrap-panic permit) { active: false })))))

;; Update permit emission levels (only by administrator)
(define-public (update-permit-level (permit-id uint) (new-max-level uint))
  (let ((current-admin (var-get administrator))
        (permit (map-get? permits {permit-id: permit-id})))
    (asserts! (is-eq tx-sender current-admin) (err ERR_UNAUTHORIZED))
    (asserts! (is-some permit) (err ERR_NOT_FOUND))

    (ok (map-set permits
      { permit-id: permit-id }
      (merge (unwrap-panic permit) { max-level: new-max-level })))))

;; Get permit details
(define-read-only (get-permit (permit-id uint))
  (map-get? permits {permit-id: permit-id}))

;; Check if a permit is active
(define-read-only (is-permit-active (permit-id uint))
  (match (map-get? permits {permit-id: permit-id})
    permit (get active permit)
    false))

;; Get maximum emission level for a given permit
(define-read-only (get-max-emission-level (permit-id uint))
  (match (map-get? permits {permit-id: permit-id})
    permit (get max-level permit)
    u0))

;; Transfer admin rights
(define-public (transfer-administrator (new-admin principal))
  (let ((current-admin (var-get administrator)))
    (asserts! (is-eq tx-sender current-admin) (err ERR_UNAUTHORIZED))
    (var-set administrator new-admin)
    (ok new-admin)))
