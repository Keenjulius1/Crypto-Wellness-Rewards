(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-INSUFFICIENT-BALANCE (err u104))
(define-constant ERR-INVALID-ACTIVITY (err u105))
(define-constant ERR-DAILY-LIMIT-REACHED (err u106))
(define-constant ERR-GOAL-NOT-MET (err u107))

(define-constant REWARD-TOKEN-NAME "Wellness Token")
(define-constant REWARD-TOKEN-SYMBOL "WELL")
(define-constant REWARD-TOKEN-DECIMALS u6)
(define-constant REWARD-TOKEN-SUPPLY u1000000000000)

(define-constant STEPS-GOAL u10000)
(define-constant EXERCISE-GOAL u30)
(define-constant DAILY-STEPS-REWARD u100000000)
(define-constant DAILY-EXERCISE-REWARD u50000000)
(define-constant WEEKLY-BONUS u200000000)
(define-constant STREAK-BONUS u75000000)

(define-fungible-token wellness-token REWARD-TOKEN-SUPPLY)

(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var total-users uint u0)
(define-data-var total-rewards-distributed uint u0)

(define-map user-profiles
    principal
    {
        total-steps: uint,
        total-exercise-minutes: uint,
        current-streak: uint,
        last-activity-day: uint,
        weekly-steps: uint,
        weekly-exercise: uint,
        week-start: uint,
        total-rewards: uint,
        level: uint,
    }
)

(define-map daily-activities
    {
        user: principal,
        day: uint,
    }
    {
        steps: uint,
        exercise-minutes: uint,
        rewards-claimed: uint,
        goals-met: uint,
    }
)

(define-map activity-goals
    uint
    {
        steps-goal: uint,
        exercise-goal: uint,
        steps-reward: uint,
        exercise-reward: uint,
    }
)

(define-map leaderboard-weekly
    uint
    {
        user: principal,
        total-points: uint,
        rank: uint,
    }
)

(define-public (transfer
        (amount uint)
        (from principal)
        (to principal)
        (memo (optional (buff 34)))
    )
    (begin
        (asserts! (or (is-eq from tx-sender) (is-eq from CONTRACT-OWNER))
            ERR-OWNER-ONLY
        )
        (ft-transfer? wellness-token amount from to)
    )
)

(define-read-only (get-name)
    (ok REWARD-TOKEN-NAME)
)

(define-read-only (get-symbol)
    (ok REWARD-TOKEN-SYMBOL)
)

(define-read-only (get-decimals)
    (ok REWARD-TOKEN-DECIMALS)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance wellness-token who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply wellness-token))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri))
)

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (var-set token-uri (some value))
        (ok true)
    )
)

(define-public (register-user)
    (let ((current-day (get-current-day)))
        (asserts! (is-none (map-get? user-profiles tx-sender)) ERR-ALREADY-EXISTS)
        (map-set user-profiles tx-sender {
            total-steps: u0,
            total-exercise-minutes: u0,
            current-streak: u0,
            last-activity-day: u0,
            weekly-steps: u0,
            weekly-exercise: u0,
            week-start: current-day,
            total-rewards: u0,
            level: u1,
        })
        (var-set total-users (+ (var-get total-users) u1))
        (ok true)
    )
)

(define-public (log-activity
        (steps uint)
        (exercise-minutes uint)
    )
    (let (
            (current-day (get-current-day))
            (user-profile (unwrap! (map-get? user-profiles tx-sender) ERR-NOT-FOUND))
            (existing-activity (map-get? daily-activities {
                user: tx-sender,
                day: current-day,
            }))
        )
        (asserts! (> steps u0) ERR-INVALID-ACTIVITY)
        (asserts! (is-none existing-activity) ERR-DAILY-LIMIT-REACHED)

        (let (
                (new-streak (if (is-eq (get last-activity-day user-profile)
                        (- current-day u1)
                    )
                    (+ (get current-streak user-profile) u1)
                    (if (is-eq (get last-activity-day user-profile) current-day)
                        (get current-streak user-profile)
                        u1
                    )
                ))
                (is-new-week (>= current-day (+ (get week-start user-profile) u7)))
                (weekly-steps (if is-new-week
                    steps
                    (+ (get weekly-steps user-profile) steps)
                ))
                (weekly-exercise (if is-new-week
                    exercise-minutes
                    (+ (get weekly-exercise user-profile) exercise-minutes)
                ))
                (week-start (if is-new-week
                    current-day
                    (get week-start user-profile)
                ))
            )
            (map-set daily-activities {
                user: tx-sender,
                day: current-day,
            } {
                steps: steps,
                exercise-minutes: exercise-minutes,
                rewards-claimed: u0,
                goals-met: u0,
            })

            (map-set user-profiles tx-sender
                (merge user-profile {
                    total-steps: (+ (get total-steps user-profile) steps),
                    total-exercise-minutes: (+ (get total-exercise-minutes user-profile) exercise-minutes),
                    current-streak: new-streak,
                    last-activity-day: current-day,
                    weekly-steps: weekly-steps,
                    weekly-exercise: weekly-exercise,
                    week-start: week-start,
                })
            )

            (ok true)
        )
    )
)

(define-public (claim-daily-rewards)
    (let (
            (current-day (get-current-day))
            (daily-activity (unwrap!
                (map-get? daily-activities {
                    user: tx-sender,
                    day: current-day,
                })
                ERR-NOT-FOUND
            ))
            (user-profile (unwrap! (map-get? user-profiles tx-sender) ERR-NOT-FOUND))
        )
        (asserts! (is-eq (get rewards-claimed daily-activity) u0)
            ERR-DAILY-LIMIT-REACHED
        )

        (let (
                (steps-met (>= (get steps daily-activity) STEPS-GOAL))
                (exercise-met (>= (get exercise-minutes daily-activity) EXERCISE-GOAL))
                (steps-reward (if steps-met
                    DAILY-STEPS-REWARD
                    u0
                ))
                (exercise-reward (if exercise-met
                    DAILY-EXERCISE-REWARD
                    u0
                ))
                (streak-reward (if (and
                        steps-met
                        exercise-met
                        (>= (get current-streak user-profile) u7)
                    )
                    STREAK-BONUS
                    u0
                ))
                (total-reward (+ steps-reward exercise-reward streak-reward))
                (goals-met (+
                    (if steps-met
                        u1
                        u0
                    )
                    (if exercise-met
                        u1
                        u0
                    )))
            )
            (asserts! (> total-reward u0) ERR-GOAL-NOT-MET)

            (try! (ft-mint? wellness-token total-reward tx-sender))

            (map-set daily-activities {
                user: tx-sender,
                day: current-day,
            }
                (merge daily-activity {
                    rewards-claimed: total-reward,
                    goals-met: goals-met,
                })
            )

            (map-set user-profiles tx-sender
                (merge user-profile {
                    total-rewards: (+ (get total-rewards user-profile) total-reward),
                    level: (calculate-user-level (+ (get total-rewards user-profile) total-reward)),
                })
            )

            (var-set total-rewards-distributed
                (+ (var-get total-rewards-distributed) total-reward)
            )
            (ok total-reward)
        )
    )
)

(define-public (claim-weekly-bonus)
    (let (
            (current-day (get-current-day))
            (user-profile (unwrap! (map-get? user-profiles tx-sender) ERR-NOT-FOUND))
        )
        (asserts! (>= current-day (+ (get week-start user-profile) u7))
            ERR-GOAL-NOT-MET
        )
        (asserts! (>= (get weekly-steps user-profile) (* STEPS-GOAL u7))
            ERR-GOAL-NOT-MET
        )
        (asserts! (>= (get weekly-exercise user-profile) (* EXERCISE-GOAL u7))
            ERR-GOAL-NOT-MET
        )

        (try! (ft-mint? wellness-token WEEKLY-BONUS tx-sender))

        (map-set user-profiles tx-sender
            (merge user-profile {
                weekly-steps: u0,
                weekly-exercise: u0,
                week-start: current-day,
                total-rewards: (+ (get total-rewards user-profile) WEEKLY-BONUS),
            })
        )

        (var-set total-rewards-distributed
            (+ (var-get total-rewards-distributed) WEEKLY-BONUS)
        )
        (ok WEEKLY-BONUS)
    )
)

(define-read-only (get-user-profile (user principal))
    (map-get? user-profiles user)
)

(define-read-only (get-daily-activity
        (user principal)
        (day uint)
    )
    (map-get? daily-activities {
        user: user,
        day: day,
    })
)

(define-read-only (get-current-day)
    (/ stacks-block-height u144)
)

(define-read-only (calculate-user-level (total-rewards uint))
    (if (>= total-rewards u10000000000)
        u10
        (if (>= total-rewards u5000000000)
            u9
            (if (>= total-rewards u2000000000)
                u8
                (if (>= total-rewards u1000000000)
                    u7
                    (if (>= total-rewards u500000000)
                        u6
                        (if (>= total-rewards u200000000)
                            u5
                            (if (>= total-rewards u100000000)
                                u4
                                (if (>= total-rewards u50000000)
                                    u3
                                    (if (>= total-rewards u10000000)
                                        u2
                                        u1
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
)

(define-read-only (get-total-stats)
    {
        total-users: (var-get total-users),
        total-rewards-distributed: (var-get total-rewards-distributed),
        total-supply: (ft-get-supply wellness-token),
    }
)

(define-read-only (get-user-rank (user principal))
    (let ((user-profile (map-get? user-profiles user)))
        (match user-profile
            profile (some (get total-rewards profile))
            none
        )
    )
)

(define-public (mint-tokens
        (amount uint)
        (recipient principal)
    )
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (ft-mint? wellness-token amount recipient)
    )
)

(define-public (burn-tokens (amount uint))
    (begin
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (ft-burn? wellness-token amount tx-sender)
    )
)

(map-set activity-goals u1 {
    steps-goal: STEPS-GOAL,
    exercise-goal: EXERCISE-GOAL,
    steps-reward: DAILY-STEPS-REWARD,
    exercise-reward: DAILY-EXERCISE-REWARD,
})
