;; Reporting Contract
;; Generates authenticated compliance disclosures

(define-data-var administrator principal tx-sender)

;; Reports data structure
(define-map reports
  { report-id: uint }
  {
    facility-id: uint,
    period-start: uint,
    period-end: uint,
    report-date: uint,
    report-hash: (buff 32),
    submitter: principal,
    approved: bool,
    approval-date: uint,
    approver: principal
  }
)

;; Counter for report IDs
(define-data-var report-counter uint u0)

;; Error codes
(define-constant ERR_UNAUTHORIZED u1000)
(define-constant ERR_NOT_FOUND u1002)
(define-constant ERR_INVALID_DATE_RANGE u1007)
(define-constant ERR_ALREADY_APPROVED u1008)

;; Submit a compliance report
(define-public (submit-report
                (facility-id uint)
                (period-start uint)
                (period-end uint)
                (report-hash (buff 32)))
  (let ((report-id (+ (var-get report-counter) u1)))
    (asserts! (< period-start period-end) (err ERR_INVALID_DATE_RANGE))
    (asserts! (<= period-end block-height) (err ERR_INVALID_DATE_RANGE))

    (var-set report-counter report-id)
    (ok (map-insert reports
      { report-id: report-id }
      {
        facility-id: facility-id,
        period-start: period-start,
        period-end: period-end,
        report-date: block-height,
        report-hash: report-hash,
        submitter: tx-sender,
        approved: false,
        approval-date: u0,
        approver: tx-sender  ;; Default value, will be updated on approval
      }))))

;; Approve a report (only by administrator)
(define-public (approve-report (report-id uint))
  (let ((current-admin (var-get administrator))
        (report (map-get? reports {report-id: report-id})))
    (asserts! (is-eq tx-sender current-admin) (err ERR_UNAUTHORIZED))
    (asserts! (is-some report) (err ERR_NOT_FOUND))
    (asserts! (not (get approved (unwrap-panic report))) (err ERR_ALREADY_APPROVED))

    (ok (map-set reports
      { report-id: report-id }
      (merge (unwrap-panic report)
             { approved: true, approval-date: block-height, approver: tx-sender })))))

;; Get report details
(define-read-only (get-report (report-id uint))
  (map-get? reports {report-id: report-id}))

;; Check if a report is approved
(define-read-only (is-report-approved (report-id uint))
  (match (map-get? reports {report-id: report-id})
    report (get approved report)
    false))

;; Verify report authenticity
(define-read-only (verify-report-hash (report-id uint) (hash-to-verify (buff 32)))
  (match (map-get? reports {report-id: report-id})
    report (is-eq (get report-hash report) hash-to-verify)
    false))

;; Transfer admin rights
(define-public (transfer-administrator (new-admin principal))
  (let ((current-admin (var-get administrator)))
    (asserts! (is-eq tx-sender current-admin) (err ERR_UNAUTHORIZED))
    (var-set administrator new-admin)
    (ok new-admin)))
