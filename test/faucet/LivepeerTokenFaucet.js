import RPC from "../../utils/rpc"
import expectThrow from "../helpers/expectThrow"

const LivepeerTokenFaucet = artifacts.require("LivepeerTokenFaucet")
const LivepeerToken = artifacts.require("LivepeerToken")

contract("LivepeerTokenFaucet", accounts => {
    const faucetAmount = 10000000000000
    const requestAmount = 100
    const requestWait = 2

    let rpc
    let token
    let faucet

    before(async () => {
        rpc = new RPC(web3)
        token = await LivepeerToken.new()
        faucet = await LivepeerTokenFaucet.new(token.address, requestAmount, requestWait)

        await token.mint(faucet.address, faucetAmount)
    })

    it("sends request amount to sender", async () => {
        await faucet.request({from: accounts[1]})

        assert.equal(await token.balanceOf(accounts[1]), requestAmount, "token balance incorrect")
    })

    it("fails if sender does not wait through request time", async () => {
        await expectThrow(faucet.request({from: accounts[1]}))
    })

    it("sends request amount to sender again after request time", async () => {
        await rpc.increaseTime(2 * 60 * 60)
        await faucet.request({from: accounts[1]})

        assert.equal(await token.balanceOf(accounts[1]), requestAmount * 2, "token balance incorrect")
    })
})
