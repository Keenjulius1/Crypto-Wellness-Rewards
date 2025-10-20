(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-INSUFFICIENT-BALANCE (err u104))
(define-constant ERR-INVALID-ACTIVITY (err u105))
(define-constant ERR-DAILY-LIMIT-REACHED (err u106))
(define-constant ERR-GOAL-NOT-MET (err u107))
(define-constant ERR-ACHIEVEMENT-NOT-FOUND (err u108))
(define-constant ERR-MARKETPLACE-LISTING-EXISTS (err u109))
(define-constant ERR-MARKETPLACE-LISTING-NOT-FOUND (err u110))
(define-constant ERR-INSUFFICIENT-FUNDS (err u111))
(define-constant ERR-CANNOT-BUY-OWN-LISTING (err u112))
(define-constant ERR-PLAN-NOT-FOUND (err u113))
(define-constant ERR-PLAN-NOT-ACTIVE (err u114))
(define-constant ERR-PLAN-ALREADY-ENROLLED (err u115))
(define-constant ERR-PLAN-NOT-ENROLLED (err u116))
(define-constant ERR-MILESTONE-NOT-FOUND (err u117))
(define-constant ERR-MILESTONE-ALREADY-COMPLETED (err u118))
(define-constant ERR-INVALID-PLAN-DURATION (err u119))
(define-constant ERR-CHALLENGE-NOT-FOUND (err u120))
(define-constant ERR-CHALLENGE-EXPIRED (err u121))
(define-constant ERR-CHALLENGE-NOT-STARTED (err u122))
(define-constant ERR-CHALLENGE-ACTIVE (err u123))
(define-constant ERR-ALREADY-JOINED-CHALLENGE (err u124))
(define-constant ERR-NOT-CHALLENGE-PARTICIPANT (err u125))
(define-constant ERR-CHALLENGE-ALREADY-COMPLETED (err u126))
(define-constant ERR-INVALID-CHALLENGE-DURATION (err u127))
(define-constant ERR-INVALID-REWARD-DISTRIBUTION (err u128))

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
(define-non-fungible-token wellness-achievement uint)

(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var achievement-counter uint u0)
(define-data-var total-users uint u0)
(define-data-var total-rewards-distributed uint u0)
(define-data-var wellness-plan-counter uint u0)
(define-data-var total-plans-completed uint u0)
(define-data-var social-challenge-counter uint u0)
(define-data-var total-challenges-completed uint u0)

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

(define-map achievements
    uint
    {
        name: (string-ascii 50),
        description: (string-ascii 200),
        rarity: uint,
        requirement-type: (string-ascii 20),
        requirement-value: uint,
        owner: principal,
    }
)

(define-map marketplace-listings
    uint
    {
        achievement-id: uint,
        seller: principal,
        price: uint,
        active: bool,
    }
)

(define-map wellness-plans
    uint
    {
        name: (string-ascii 100),
        description: (string-ascii 300),
        creator: principal,
        duration-days: uint,
        daily-steps-target: uint,
        daily-exercise-target: uint,
        completion-reward: uint,
        milestone-reward: uint,
        price: uint,
        active: bool,
        total-enrolled: uint,
        total-completed: uint,
    }
)

(define-map user-plan-enrollments
    {
        user: principal,
        plan-id: uint,
    }
    {
        start-day: uint,
        progress-days: uint,
        milestones-completed: uint,
        total-rewards-earned: uint,
        completed: bool,
        completion-day: (optional uint),
    }
)

(define-map plan-daily-progress
    {
        user: principal,
        plan-id: uint,
        day: uint,
    }
    {
        steps-achieved: uint,
        exercise-achieved: uint,
        goal-met: bool,
        milestone-claimed: bool,
    }
)

(define-map social-challenges
    uint
    {
        title: (string-ascii 100),
        description: (string-ascii 300),
        creator: principal,
        start-day: uint,
        duration-days: uint,
        end-day: uint,
        entry-fee: uint,
        goal-type: (string-ascii 20),
        goal-value: uint,
        reward-distribution: uint,
        total-pool: uint,
        participant-count: uint,
        max-participants: uint,
        status: (string-ascii 20),
        winner: (optional principal),
        completed: bool,
    }
)

(define-map challenge-participants
    {
        challenge-id: uint,
        participant: principal,
    }
    {
        joined-day: uint,
        current-progress: uint,
        final-progress: uint,
        rank: uint,
        reward-claimed: uint,
    }
)

(define-map challenge-daily-progress
    {
        challenge-id: uint,
        participant: principal,
        day: uint,
    }
    {
        progress-value: uint,
        logged-at: uint,
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

(define-public (mint-achievement
        (name (string-ascii 50))
        (description (string-ascii 200))
        (rarity uint)
        (requirement-type (string-ascii 20))
        (requirement-value uint)
        (recipient principal)
    )
    (let ((achievement-id (+ (var-get achievement-counter) u1)))
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (asserts! (>= rarity u1) ERR-INVALID-AMOUNT)
        (asserts! (<= rarity u5) ERR-INVALID-AMOUNT)

        (try! (nft-mint? wellness-achievement achievement-id recipient))

        (map-set achievements achievement-id {
            name: name,
            description: description,
            rarity: rarity,
            requirement-type: requirement-type,
            requirement-value: requirement-value,
            owner: recipient,
        })

        (var-set achievement-counter achievement-id)
        (ok achievement-id)
    )
)

(define-public (transfer-achievement
        (achievement-id uint)
        (sender principal)
        (recipient principal)
    )
    (begin
        (asserts!
            (is-eq (nft-get-owner? wellness-achievement achievement-id)
                (some sender)
            )
            ERR-NOT-FOUND
        )
        (asserts! (or (is-eq tx-sender sender) (is-eq tx-sender CONTRACT-OWNER))
            ERR-OWNER-ONLY
        )

        (try! (nft-transfer? wellness-achievement achievement-id sender recipient))

        (match (map-get? achievements achievement-id)
            achievement-data (map-set achievements achievement-id
                (merge achievement-data { owner: recipient })
            )
            false
        )
        (ok true)
    )
)

(define-public (list-achievement-for-sale
        (achievement-id uint)
        (price uint)
    )
    (let ((achievement-data (unwrap! (map-get? achievements achievement-id) ERR-ACHIEVEMENT-NOT-FOUND)))
        (asserts! (is-eq (get owner achievement-data) tx-sender) ERR-OWNER-ONLY)
        (asserts! (> price u0) ERR-INVALID-AMOUNT)
        (asserts! (is-none (map-get? marketplace-listings achievement-id))
            ERR-MARKETPLACE-LISTING-EXISTS
        )

        (map-set marketplace-listings achievement-id {
            achievement-id: achievement-id,
            seller: tx-sender,
            price: price,
            active: true,
        })
        (ok true)
    )
)

(define-public (buy-achievement (achievement-id uint))
    (let (
            (listing (unwrap! (map-get? marketplace-listings achievement-id)
                ERR-MARKETPLACE-LISTING-NOT-FOUND
            ))
            (achievement-data (unwrap! (map-get? achievements achievement-id)
                ERR-ACHIEVEMENT-NOT-FOUND
            ))
        )
        (asserts! (get active listing) ERR-MARKETPLACE-LISTING-NOT-FOUND)
        (asserts! (not (is-eq tx-sender (get seller listing)))
            ERR-CANNOT-BUY-OWN-LISTING
        )
        (asserts!
            (>= (ft-get-balance wellness-token tx-sender) (get price listing))
            ERR-INSUFFICIENT-FUNDS
        )

        (try! (ft-transfer? wellness-token (get price listing) tx-sender
            (get seller listing)
        ))
        (try! (nft-transfer? wellness-achievement achievement-id (get seller listing)
            tx-sender
        ))

        (map-set achievements achievement-id
            (merge achievement-data { owner: tx-sender })
        )

        (map-delete marketplace-listings achievement-id)
        (ok true)
    )
)

(define-public (cancel-listing (achievement-id uint))
    (let ((listing (unwrap! (map-get? marketplace-listings achievement-id)
            ERR-MARKETPLACE-LISTING-NOT-FOUND
        )))
        (asserts! (is-eq tx-sender (get seller listing)) ERR-OWNER-ONLY)
        (map-delete marketplace-listings achievement-id)
        (ok true)
    )
)

(define-read-only (get-achievement (achievement-id uint))
    (map-get? achievements achievement-id)
)

(define-read-only (get-marketplace-listing (achievement-id uint))
    (map-get? marketplace-listings achievement-id)
)

(define-read-only (get-achievement-owner (achievement-id uint))
    (nft-get-owner? wellness-achievement achievement-id)
)

(define-read-only (get-achievement-counter)
    (var-get achievement-counter)
)

(define-public (create-wellness-plan
        (name (string-ascii 100))
        (description (string-ascii 300))
        (duration-days uint)
        (daily-steps-target uint)
        (daily-exercise-target uint)
        (completion-reward uint)
        (milestone-reward uint)
        (price uint)
    )
    (let ((plan-id (+ (var-get wellness-plan-counter) u1)))
        (asserts! (> duration-days u0) ERR-INVALID-PLAN-DURATION)
        (asserts! (<= duration-days u365) ERR-INVALID-PLAN-DURATION)
        (asserts! (> daily-steps-target u0) ERR-INVALID-ACTIVITY)
        (asserts! (> daily-exercise-target u0) ERR-INVALID-ACTIVITY)
        (asserts! (> completion-reward u0) ERR-INVALID-AMOUNT)
        (asserts! (> milestone-reward u0) ERR-INVALID-AMOUNT)

        (map-set wellness-plans plan-id {
            name: name,
            description: description,
            creator: tx-sender,
            duration-days: duration-days,
            daily-steps-target: daily-steps-target,
            daily-exercise-target: daily-exercise-target,
            completion-reward: completion-reward,
            milestone-reward: milestone-reward,
            price: price,
            active: true,
            total-enrolled: u0,
            total-completed: u0,
        })

        (var-set wellness-plan-counter plan-id)
        (ok plan-id)
    )
)

(define-public (enroll-in-wellness-plan (plan-id uint))
    (let (
            (plan (unwrap! (map-get? wellness-plans plan-id) ERR-PLAN-NOT-FOUND))
            (current-day (get-current-day))
        )
        (asserts! (get active plan) ERR-PLAN-NOT-ACTIVE)
        (asserts!
            (is-none (map-get? user-plan-enrollments {
                user: tx-sender,
                plan-id: plan-id,
            }))
            ERR-PLAN-ALREADY-ENROLLED
        )
        (asserts! (>= (ft-get-balance wellness-token tx-sender) (get price plan))
            ERR-INSUFFICIENT-FUNDS
        )

        (try! (ft-transfer? wellness-token (get price plan) tx-sender
            (get creator plan)
        ))

        (map-set user-plan-enrollments {
            user: tx-sender,
            plan-id: plan-id,
        } {
            start-day: current-day,
            progress-days: u0,
            milestones-completed: u0,
            total-rewards-earned: u0,
            completed: false,
            completion-day: none,
        })

        (map-set wellness-plans plan-id
            (merge plan { total-enrolled: (+ (get total-enrolled plan) u1) })
        )
        (ok true)
    )
)

(define-public (log-plan-progress
        (plan-id uint)
        (steps uint)
        (exercise-minutes uint)
    )
    (let (
            (plan (unwrap! (map-get? wellness-plans plan-id) ERR-PLAN-NOT-FOUND))
            (enrollment (unwrap!
                (map-get? user-plan-enrollments {
                    user: tx-sender,
                    plan-id: plan-id,
                })
                ERR-PLAN-NOT-ENROLLED
            ))
            (current-day (get-current-day))
            (progress-day (+ (- current-day (get start-day enrollment)) u1))
        )
        (asserts! (not (get completed enrollment)) ERR-PLAN-NOT-ACTIVE)
        (asserts! (<= progress-day (get duration-days plan)) ERR-PLAN-NOT-ACTIVE)
        (asserts! (> steps u0) ERR-INVALID-ACTIVITY)
        (asserts!
            (is-none (map-get? plan-daily-progress {
                user: tx-sender,
                plan-id: plan-id,
                day: progress-day,
            }))
            ERR-DAILY-LIMIT-REACHED
        )

        (let (
                (steps-goal-met (>= steps (get daily-steps-target plan)))
                (exercise-goal-met (>= exercise-minutes (get daily-exercise-target plan)))
                (daily-goal-met (and steps-goal-met exercise-goal-met))
            )
            (map-set plan-daily-progress {
                user: tx-sender,
                plan-id: plan-id,
                day: progress-day,
            } {
                steps-achieved: steps,
                exercise-achieved: exercise-minutes,
                goal-met: daily-goal-met,
                milestone-claimed: false,
            })

            (map-set user-plan-enrollments {
                user: tx-sender,
                plan-id: plan-id,
            }
                (merge enrollment { progress-days: progress-day })
            )
            (ok daily-goal-met)
        )
    )
)

(define-public (claim-milestone-reward
        (plan-id uint)
        (milestone-day uint)
    )
    (let (
            (plan (unwrap! (map-get? wellness-plans plan-id) ERR-PLAN-NOT-FOUND))
            (enrollment (unwrap!
                (map-get? user-plan-enrollments {
                    user: tx-sender,
                    plan-id: plan-id,
                })
                ERR-PLAN-NOT-ENROLLED
            ))
            (daily-progress (unwrap!
                (map-get? plan-daily-progress {
                    user: tx-sender,
                    plan-id: plan-id,
                    day: milestone-day,
                })
                ERR-MILESTONE-NOT-FOUND
            ))
        )
        (asserts! (get goal-met daily-progress) ERR-GOAL-NOT-MET)
        (asserts! (not (get milestone-claimed daily-progress))
            ERR-MILESTONE-ALREADY-COMPLETED
        )
        (asserts! (<= milestone-day (get progress-days enrollment))
            ERR-MILESTONE-NOT-FOUND
        )

        (try! (ft-mint? wellness-token (get milestone-reward plan) tx-sender))

        (map-set plan-daily-progress {
            user: tx-sender,
            plan-id: plan-id,
            day: milestone-day,
        }
            (merge daily-progress { milestone-claimed: true })
        )

        (map-set user-plan-enrollments {
            user: tx-sender,
            plan-id: plan-id,
        }
            (merge enrollment {
                milestones-completed: (+ (get milestones-completed enrollment) u1),
                total-rewards-earned: (+ (get total-rewards-earned enrollment)
                    (get milestone-reward plan)
                ),
            })
        )

        (var-set total-rewards-distributed
            (+ (var-get total-rewards-distributed) (get milestone-reward plan))
        )
        (ok (get milestone-reward plan))
    )
)

(define-public (complete-wellness-plan (plan-id uint))
    (let (
            (plan (unwrap! (map-get? wellness-plans plan-id) ERR-PLAN-NOT-FOUND))
            (enrollment (unwrap!
                (map-get? user-plan-enrollments {
                    user: tx-sender,
                    plan-id: plan-id,
                })
                ERR-PLAN-NOT-ENROLLED
            ))
            (current-day (get-current-day))
        )
        (asserts! (not (get completed enrollment))
            ERR-MILESTONE-ALREADY-COMPLETED
        )
        (asserts! (>= (get progress-days enrollment) (get duration-days plan))
            ERR-GOAL-NOT-MET
        )

        (try! (ft-mint? wellness-token (get completion-reward plan) tx-sender))

        (map-set user-plan-enrollments {
            user: tx-sender,
            plan-id: plan-id,
        }
            (merge enrollment {
                completed: true,
                completion-day: (some current-day),
                total-rewards-earned: (+ (get total-rewards-earned enrollment)
                    (get completion-reward plan)
                ),
            })
        )

        (map-set wellness-plans plan-id
            (merge plan { total-completed: (+ (get total-completed plan) u1) })
        )

        (var-set total-plans-completed (+ (var-get total-plans-completed) u1))
        (var-set total-rewards-distributed
            (+ (var-get total-rewards-distributed) (get completion-reward plan))
        )
        (ok (get completion-reward plan))
    )
)

(define-read-only (get-wellness-plan (plan-id uint))
    (map-get? wellness-plans plan-id)
)

(define-read-only (get-user-plan-enrollment
        (user principal)
        (plan-id uint)
    )
    (map-get? user-plan-enrollments {
        user: user,
        plan-id: plan-id,
    })
)

(define-read-only (get-plan-daily-progress
        (user principal)
        (plan-id uint)
        (day uint)
    )
    (map-get? plan-daily-progress {
        user: user,
        plan-id: plan-id,
        day: day,
    })
)

(define-read-only (get-wellness-plan-stats)
    {
        total-plans: (var-get wellness-plan-counter),
        total-plans-completed: (var-get total-plans-completed),
    }
)

;; Social Challenges Functions

(define-public (create-social-challenge
        (title (string-ascii 100))
        (description (string-ascii 300))
        (duration-days uint)
        (entry-fee uint)
        (goal-type (string-ascii 20))
        (goal-value uint)
        (reward-distribution uint)
        (max-participants uint)
    )
    (let (
            (challenge-id (+ (var-get social-challenge-counter) u1))
            (current-day (get-current-day))
            (end-day (+ current-day duration-days))
        )
        (asserts! (> duration-days u0) ERR-INVALID-CHALLENGE-DURATION)
        (asserts! (<= duration-days u30) ERR-INVALID-CHALLENGE-DURATION)
        (asserts! (> entry-fee u0) ERR-INVALID-AMOUNT)
        (asserts! (> goal-value u0) ERR-INVALID-ACTIVITY)
        (asserts! (> max-participants u1) ERR-INVALID-AMOUNT)
        (asserts! (<= max-participants u100) ERR-INVALID-AMOUNT)
        (asserts! (>= reward-distribution u1) ERR-INVALID-REWARD-DISTRIBUTION)
        (asserts! (<= reward-distribution u3) ERR-INVALID-REWARD-DISTRIBUTION)

        (map-set social-challenges challenge-id {
            title: title,
            description: description,
            creator: tx-sender,
            start-day: (+ current-day u1),
            duration-days: duration-days,
            end-day: end-day,
            entry-fee: entry-fee,
            goal-type: goal-type,
            goal-value: goal-value,
            reward-distribution: reward-distribution,
            total-pool: u0,
            participant-count: u0,
            max-participants: max-participants,
            status: "open",
            winner: none,
            completed: false,
        })

        (var-set social-challenge-counter challenge-id)
        (ok challenge-id)
    )
)

(define-public (join-social-challenge (challenge-id uint))
    (let (
            (challenge (unwrap! (map-get? social-challenges challenge-id)
                ERR-CHALLENGE-NOT-FOUND
            ))
            (current-day (get-current-day))
            (existing-participation (map-get? challenge-participants {
                challenge-id: challenge-id,
                participant: tx-sender,
            }))
        )
        (asserts! (is-none existing-participation) ERR-ALREADY-JOINED-CHALLENGE)
        (asserts! (< current-day (get start-day challenge)) ERR-CHALLENGE-NOT-STARTED)
        (asserts! (< (get participant-count challenge) (get max-participants challenge))
            ERR-DAILY-LIMIT-REACHED
        )
        (asserts! (>= (ft-get-balance wellness-token tx-sender) (get entry-fee challenge))
            ERR-INSUFFICIENT-FUNDS
        )

        (try! (ft-transfer? wellness-token (get entry-fee challenge) tx-sender
            (get creator challenge)
        ))

        (map-set challenge-participants {
            challenge-id: challenge-id,
            participant: tx-sender,
        } {
            joined-day: current-day,
            current-progress: u0,
            final-progress: u0,
            rank: u0,
            reward-claimed: u0,
        })

        (map-set social-challenges challenge-id
            (merge challenge {
                total-pool: (+ (get total-pool challenge) (get entry-fee challenge)),
                participant-count: (+ (get participant-count challenge) u1),
                status: (if (is-eq (+ (get participant-count challenge) u1)
                        (get max-participants challenge)
                    )
                    "full"
                    "open"
                ),
            })
        )
        (ok true)
    )
)

(define-public (log-challenge-progress
        (challenge-id uint)
        (progress-value uint)
    )
    (let (
            (challenge (unwrap! (map-get? social-challenges challenge-id)
                ERR-CHALLENGE-NOT-FOUND
            ))
            (current-day (get-current-day))
            (participation (unwrap!
                (map-get? challenge-participants {
                    challenge-id: challenge-id,
                    participant: tx-sender,
                })
                ERR-NOT-CHALLENGE-PARTICIPANT
            ))
            (existing-progress (map-get? challenge-daily-progress {
                challenge-id: challenge-id,
                participant: tx-sender,
                day: current-day,
            }))
        )
        (asserts! (>= current-day (get start-day challenge)) ERR-CHALLENGE-NOT-STARTED)
        (asserts! (< current-day (get end-day challenge)) ERR-CHALLENGE-EXPIRED)
        (asserts! (> progress-value u0) ERR-INVALID-ACTIVITY)
        (asserts! (is-none existing-progress) ERR-DAILY-LIMIT-REACHED)

        (map-set challenge-daily-progress {
            challenge-id: challenge-id,
            participant: tx-sender,
            day: current-day,
        } {
            progress-value: progress-value,
            logged-at: current-day,
        })

        (map-set challenge-participants {
            challenge-id: challenge-id,
            participant: tx-sender,
        }
            (merge participation {
                current-progress: (+ (get current-progress participation) progress-value),
            })
        )
        (ok true)
    )
)

(define-public (complete-social-challenge (challenge-id uint))
    (let (
            (challenge (unwrap! (map-get? social-challenges challenge-id)
                ERR-CHALLENGE-NOT-FOUND
            ))
            (current-day (get-current-day))
        )
        (asserts! (>= current-day (get end-day challenge)) ERR-CHALLENGE-ACTIVE)
        (asserts! (not (get completed challenge)) ERR-CHALLENGE-ALREADY-COMPLETED)
        (asserts! (> (get participant-count challenge) u0) ERR-NOT-FOUND)

        (let ((winner (get-challenge-winner challenge-id)))
            (match winner
                winner-principal
                (begin
                    (try! (ft-mint? wellness-token (get total-pool challenge) winner-principal))
                    (map-set social-challenges challenge-id
                        (merge challenge {
                            status: "completed",
                            winner: (some winner-principal),
                            completed: true,
                        })
                    )
                )
                (map-set social-challenges challenge-id
                    (merge challenge {
                        status: "completed",
                        winner: none,
                        completed: true,
                    })
                )
            )
        )

        (var-set total-challenges-completed (+ (var-get total-challenges-completed) u1))
        (ok true)
    )
)

(define-read-only (get-challenge-winner (challenge-id uint))
    (let (
            (challenge (unwrap! (map-get? social-challenges challenge-id) none))
        )
        (if (> (get participant-count challenge) u0)
            (some (get creator challenge))
            none
        )
    )
)

(define-read-only (get-social-challenge-details (challenge-id uint))
    (map-get? social-challenges challenge-id)
)

(define-read-only (get-challenge-participant-info
        (challenge-id uint)
        (participant principal)
    )
    (map-get? challenge-participants {
        challenge-id: challenge-id,
        participant: participant,
    })
)

(define-read-only (get-challenge-daily-progress
        (challenge-id uint)
        (participant principal)
        (day uint)
    )
    (map-get? challenge-daily-progress {
        challenge-id: challenge-id,
        participant: participant,
        day: day,
    })
)

(define-read-only (get-social-challenge-stats)
    {
        total-challenges: (var-get social-challenge-counter),
        total-completed: (var-get total-challenges-completed),
    }
)
