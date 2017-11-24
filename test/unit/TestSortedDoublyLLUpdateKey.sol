pragma solidity ^0.4.17;

import "../../contracts/test/SortedDoublyLLFixture.sol";
import "truffle/Assert.sol";


contract TestSortedDoublyLLUpdateKey {
    address[] ids = [address(1), address(2), address(3), address(4), address(5), address(6)];
    uint256[] keys = [uint256(13), uint256(11), uint256(9), uint256(7), uint256(5), uint256(3)];

    SortedDoublyLLFixture fixture;

    function beforeEach() public {
        fixture = new SortedDoublyLLFixture();
        fixture.setMaxSize(10);
    }

    function test_increaseKey_noHint() public {
        fixture.insert(ids[0], keys[0], address(0), address(0));
        fixture.insert(ids[1], keys[1], ids[0], address(0));
        fixture.insert(ids[2], keys[2], ids[1], address(0));
        fixture.insert(ids[3], keys[3], ids[2], address(0));
        fixture.insert(ids[4], keys[4], ids[3], address(0));
        fixture.insert(ids[5], keys[5], ids[4], address(0));

        fixture.increaseKey(ids[3], 3, address(0), address(0));
        Assert.equal(fixture.getKey(ids[3]), keys[3] + 3, "wrong key");
        Assert.equal(fixture.getNext(ids[3]), ids[2], "wrong next");
        Assert.equal(fixture.getPrev(ids[3]), ids[1], "wrong prev");
        Assert.equal(fixture.getNext(ids[1]), ids[3], "wrong next");
        Assert.equal(fixture.getPrev(ids[2]), ids[3], "wrong prev");
    }

    function test_decreaseKey_noHint() public {
        fixture.insert(ids[0], keys[0], address(0), address(0));
        fixture.insert(ids[1], keys[1], ids[0], address(0));
        fixture.insert(ids[2], keys[2], ids[1], address(0));
        fixture.insert(ids[3], keys[3], ids[2], address(0));
        fixture.insert(ids[4], keys[4], ids[3], address(0));
        fixture.insert(ids[5], keys[5], ids[4], address(0));

        fixture.decreaseKey(ids[3], 3, address(0), address(0));
        Assert.equal(fixture.getKey(ids[3]), keys[3] - 3, "wrong key");
        Assert.equal(fixture.getNext(ids[3]), ids[5], "wrong next");
        Assert.equal(fixture.getPrev(ids[3]), ids[4], "wrong prev");
        Assert.equal(fixture.getNext(ids[4]), ids[3], "wrong next");
        Assert.equal(fixture.getPrev(ids[5]), ids[3], "wrong prev");
    }
}
