;; Sensor Data Contract
;; Tracks real-time environmental metrics

(define-data-var administrator principal tx-sender)

;; Sensor data structure
(define-map sensors
  { sensor-id: uint }
  {
    facility-id: uint,
    sensor-type: (string-ascii 50),
    location: (string-ascii 100),
    active: bool
  }
)

;; Sensor readings
(define-map sensor-readings
  { reading-id: uint }
  {
    sensor-id: uint,
    timestamp: uint,
    value: uint,
    unit: (string-ascii 20),
    reporter: principal
  }
)

;; Counters for IDs
(define-data-var sensor-counter uint u0)
(define-data-var reading-counter uint u0)

;; Error codes
(define-constant ERR_UNAUTHORIZED u1000)
(define-constant ERR_NOT_FOUND u1002)
(define-constant ERR_SENSOR_INACTIVE u1004)

;; Register a new sensor (only by administrator)
(define-public (register-sensor
                (facility-id uint)
                (sensor-type (string-ascii 50))
                (location (string-ascii 100)))
  (let ((current-admin (var-get administrator))
        (sensor-id (+ (var-get sensor-counter) u1)))
    (asserts! (is-eq tx-sender current-admin) (err ERR_UNAUTHORIZED))

    (var-set sensor-counter sensor-id)
    (ok (map-insert sensors
      { sensor-id: sensor-id }
      {
        facility-id: facility-id,
        sensor-type: sensor-type,
        location: location,
        active: true
      }))))

;; Deactivate a sensor (only by administrator)
(define-public (deactivate-sensor (sensor-id uint))
  (let ((current-admin (var-get administrator))
        (sensor (map-get? sensors {sensor-id: sensor-id})))
    (asserts! (is-eq tx-sender current-admin) (err ERR_UNAUTHORIZED))
    (asserts! (is-some sensor) (err ERR_NOT_FOUND))

    (ok (map-set sensors
      { sensor-id: sensor-id }
      (merge (unwrap-panic sensor) { active: false })))))

;; Submit a sensor reading
(define-public (submit-reading
                (sensor-id uint)
                (value uint)
                (unit (string-ascii 20)))
  (let ((sensor (map-get? sensors {sensor-id: sensor-id}))
        (reading-id (+ (var-get reading-counter) u1)))
    (asserts! (is-some sensor) (err ERR_NOT_FOUND))
    (asserts! (get active (unwrap-panic sensor)) (err ERR_SENSOR_INACTIVE))

    (var-set reading-counter reading-id)
    (ok (map-insert sensor-readings
      { reading-id: reading-id }
      {
        sensor-id: sensor-id,
        timestamp: block-height,
        value: value,
        unit: unit,
        reporter: tx-sender
      }))))

;; Get sensor details
(define-read-only (get-sensor (sensor-id uint))
  (map-get? sensors {sensor-id: sensor-id}))

;; Get reading details
(define-read-only (get-reading (reading-id uint))
  (map-get? sensor-readings {reading-id: reading-id}))

;; Check if a sensor is active
(define-read-only (is-sensor-active (sensor-id uint))
  (match (map-get? sensors {sensor-id: sensor-id})
    sensor (get active sensor)
    false))

;; Transfer admin rights
(define-public (transfer-administrator (new-admin principal))
  (let ((current-admin (var-get administrator)))
    (asserts! (is-eq tx-sender current-admin) (err ERR_UNAUTHORIZED))
    (var-set administrator new-admin)
    (ok new-admin)))
