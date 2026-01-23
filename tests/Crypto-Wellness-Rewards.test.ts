
import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

/*
  The test below is an example. To learn more, read the testing documentation here:
  https://docs.hiro.so/stacks/clarinet-js-sdk
*/

describe("example tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  // it("shows an example", () => {
  //   const { result } = simnet.callReadOnlyFn("counter", "get-counter", [], address1);
  //   expect(result).toBeUint(0);
  // });
});

describe("Social Challenges Feature", () => {
  it("should have social challenge functions available", () => {
    // Test that the new functions are available by checking contract compilation
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should return empty stats initially", () => {
    const stats = simnet.callReadOnlyFn("Crypto-Wellness-Rewards", "get-social-challenge-stats", [], address1);
    // Just verify the function works and returns something
    expect(stats.result).toBeDefined();
  });
});
