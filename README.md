# 🏃‍♂️ Crypto Wellness Rewards

> Reward healthy behavior with cryptocurrency tokens! 💪

A Clarity smart contract that incentivizes healthy lifestyle choices by rewarding users with `WELL` tokens for achieving daily fitness goals.

## 🎯 Features

- **Daily Step Tracking**: Earn rewards for hitting 10,000+ steps
- **Exercise Logging**: Get tokens for 30+ minutes of exercise  
- **Streak Bonuses**: Extra rewards for maintaining 7-day streaks
- **Weekly Challenges**: Bonus tokens for completing weekly goals
- **User Levels**: Progress through 10 levels based on total rewards
- **Leaderboards**: Compete with other users
- **Token Management**: Full fungible token implementation

## 🪙 Token Details

- **Name**: Wellness Token
- **Symbol**: WELL  
- **Decimals**: 6
- **Total Supply**: 1,000,000 WELL

## 🎁 Reward Structure

| Achievement | Reward | Requirements |
|-------------|--------|--------------|
| Daily Steps | 100 WELL | 10,000+ steps |
| Daily Exercise | 50 WELL | 30+ minutes |
| 7-Day Streak | 75 WELL | Both goals for 7 days |
| Weekly Bonus | 200 WELL | All daily goals for a week |

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://docs.hiro.so/stacks/clarinet) installed
- Stacks wallet

### Installation

```bash
git clone <repository-url>
cd crypto-wellness-rewards
clarinet check
```

### Usage

#### 1. Register as User 👤

```clarity
(contract-call? .crypto-wellness-rewards register-user)
```

#### 2. Log Daily Activity 📊

```clarity
(contract-call? .crypto-wellness-rewards log-activity u12000 u45)
;; Log 12,000 steps and 45 minutes of exercise
```

#### 3. Claim Daily Rewards 💰

```clarity
(contract-call? .crypto-wellness-rewards claim-daily-rewards)
```

#### 4. Claim Weekly Bonus 🎉

```clarity
(contract-call? .crypto-wellness-rewards claim-weekly-bonus)
```

## 📋 Contract Functions

### Public Functions

| Function | Description |
|----------|-------------|
| `register-user` | Register as a new user |
| `log-activity` | Log daily steps and exercise |
| `claim-daily-rewards` | Claim rewards for daily goals |
| `claim-weekly-bonus` | Claim weekly completion bonus |
| `transfer` | Transfer tokens between users |
| `mint-tokens` | Admin function to mint tokens |
| `burn-tokens` | Burn your own tokens |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-user-profile` | Get user's fitness profile |
| `get-daily-activity` | Get activity for specific day |
| `get-balance` | Check token balance |
| `get-total-stats` | Get platform statistics |
| `get-current-day` | Get current day number |

## 📈 User Levels

Progress through 10 levels based on total rewards earned:

- **Level 1**: 0+ WELL
- **Level 2**: 10+ WELL  
- **Level 3**: 50+ WELL
- **Level 4**: 100+ WELL
- **Level 5**: 200+ WELL
- **Level 6**: 500+ WELL
- **Level 7**: 1,000+ WELL
- **Level 8**: 2,000+ WELL
- **Level 9**: 5,000+ WELL
- **Level 10**: 10,000+ WELL

## 🧪 Testing

```bash
npm install
npm test
```

## 🔧 Development

### Compile Contract

```bash
clarinet check
```

### Deploy to Testnet

```bash
clarinet publish --testnet
```

## 📊 Example Workflow

1. **Register**: `(contract-call? .crypto-wellness-rewards register-user)`
2. **Log Activity**: `(contract-call? .crypto-wellness-rewards log-activity u15000 u60)`
3. **Claim Rewards**: `(contract-call? .crypto-wellness-rewards claim-daily-rewards)`
4. **Check Balance**: `(contract-call? .crypto-wellness-rewards get-balance tx-sender)`

## 🛡️ Security

- Owner-only functions for minting
- Daily activity limits prevent spam
- Input validation for all user data
- Streak calculation prevents gaming

## 📄 License

MIT License

**Start your wellness journey today! 🌟**

*Get fit, get paid, get healthy!* 💪
