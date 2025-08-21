
;; title: CoffeeChainCoin
;; version: 1.0.0
;; summary: A token reward distribution smart contract for daily coffee purchase rewards programs
;; description: CoffeeChainCoin allows coffee shops to distribute reward tokens to customers for daily coffee purchases

;; traits
;; Implements SIP-010 fungible token standard

;; token definitions
(define-fungible-token coffee-chain-coin)

;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-already-claimed-today (err u103))
(define-constant err-shop-not-registered (err u104))
(define-constant err-invalid-amount (err u105))

;; Token metadata
(define-constant token-name "CoffeeChainCoin")
(define-constant token-symbol "CCC")
(define-constant token-decimals u6)
(define-constant token-uri "https://coffeechaincoin.com/metadata.json")

;; Reward amounts (in micro-tokens, 6 decimals)
(define-constant daily-reward u1000000) ;; 1 CCC per coffee purchase
(define-constant max-daily-claims u3)   ;; Maximum 3 claims per day

;; data vars
(define-data-var token-total-supply uint u0)
(define-data-var rewards-pool uint u0)

;; data maps
(define-map coffee-shops principal bool)
(define-map last-claim-block principal uint)
(define-map daily-claim-count principal uint)
(define-map balances principal uint)

;; public functions

;; Initialize the contract with initial rewards pool
(define-public (initialize (initial-pool uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> initial-pool u0) err-invalid-amount)
    (try! (ft-mint? coffee-chain-coin initial-pool contract-owner))
    (var-set token-total-supply initial-pool)
    (var-set rewards-pool initial-pool)
    (ok true)))

;; Register a coffee shop to distribute rewards
(define-public (register-coffee-shop (shop principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set coffee-shops shop true)
    (ok true)))

;; Remove a coffee shop from the program
(define-public (unregister-coffee-shop (shop principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-delete coffee-shops shop)
    (ok true)))

;; Coffee shop distributes reward to customer for coffee purchase
(define-public (distribute-reward (customer principal))
  (let (
    (current-block block-height)
    (last-claim (default-to u0 (map-get? last-claim-block customer)))
    (daily-claims (default-to u0 (map-get? daily-claim-count customer)))
    (blocks-per-day u144) ;; Approximately 144 blocks per day (10 min blocks)
  )
    ;; Check if caller is a registered coffee shop
    (asserts! (default-to false (map-get? coffee-shops tx-sender)) err-shop-not-registered)
    
    ;; Reset daily claim count if it's a new day
    (if (>= (- current-block last-claim) blocks-per-day)
      (map-set daily-claim-count customer u0)
      true)
    
    ;; Get updated daily claims count
    (let ((updated-daily-claims (default-to u0 (map-get? daily-claim-count customer))))
      ;; Check if customer hasn't exceeded daily limit
      (asserts! (< updated-daily-claims max-daily-claims) err-already-claimed-today)
      
      ;; Check if rewards pool has sufficient balance
      (asserts! (>= (var-get rewards-pool) daily-reward) err-insufficient-balance)
      
      ;; Distribute the reward
      (try! (ft-transfer? coffee-chain-coin daily-reward contract-owner customer))
      
      ;; Update tracking variables
      (map-set last-claim-block customer current-block)
      (map-set daily-claim-count customer (+ updated-daily-claims u1))
      (var-set rewards-pool (- (var-get rewards-pool) daily-reward))
      
      (ok daily-reward))))

;; Transfer tokens between users
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-authorized)
    (ft-transfer? coffee-chain-coin amount sender recipient)))

;; Mint new tokens (owner only)
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (ft-mint? coffee-chain-coin amount recipient))
    (var-set token-total-supply (+ (var-get token-total-supply) amount))
    (ok true)))

;; Add funds to rewards pool (owner only)
(define-public (add-to-rewards-pool (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (ft-transfer? coffee-chain-coin amount tx-sender (as-contract tx-sender)))
    (var-set rewards-pool (+ (var-get rewards-pool) amount))
    (ok true)))

;; read only functions

;; Get token name
(define-read-only (get-name)
  (ok token-name))

;; Get token symbol
(define-read-only (get-symbol)
  (ok token-symbol))

;; Get token decimals
(define-read-only (get-decimals)
  (ok token-decimals))

;; Get token balance of user
(define-read-only (get-balance (user principal))
  (ok (ft-get-balance coffee-chain-coin user)))

;; Get total token supply
(define-read-only (get-total-supply)
  (ok (ft-get-supply coffee-chain-coin)))

;; Get token URI
(define-read-only (get-token-uri)
  (ok (some token-uri)))

;; Check if address is a registered coffee shop
(define-read-only (is-coffee-shop (shop principal))
  (default-to false (map-get? coffee-shops shop)))

;; Get remaining daily claims for user
(define-read-only (get-remaining-daily-claims (user principal))
  (let (
    (current-block block-height)
    (last-claim (default-to u0 (map-get? last-claim-block user)))
    (daily-claims (default-to u0 (map-get? daily-claim-count user)))
    (blocks-per-day u144)
  )
    (if (>= (- current-block last-claim) blocks-per-day)
      max-daily-claims
      (- max-daily-claims daily-claims))))

;; Get current rewards pool balance
(define-read-only (get-rewards-pool)
  (var-get rewards-pool))

;; Get daily reward amount
(define-read-only (get-daily-reward)
  daily-reward)

;; private functions

;; Helper function to check if it's a new day
(define-private (is-new-day (last-block uint) (current-block uint))
  (>= (- current-block last-block) u144))
