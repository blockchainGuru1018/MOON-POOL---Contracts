import { expect } from "chai";
import { formatEther, parseEther } from "ethers/lib/utils";
import { ethers } from "hardhat";

describe("test", function () {
  it("deposit and withdraw", async function () {
    const [owner, user] = await ethers.getSigners();
    // mock token
    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy(parseEther("2000"));
    await token.deployed();
    token.transfer(user.address, parseEther("1000"));
    // reception
    const Reception = await ethers.getContractFactory("Reception");
    const reception = await Reception.deploy(
      owner.address,
      token.address
    );
    await reception.deployed();
    
    //reserveRoom
    await reception.createRoom(owner.address, user.address, parseEther("1000"));
    // approve token
    await token.approve(reception.address, parseEther("1000"));
    await token.connect(user).approve(reception.address, parseEther("1000"));
    await reception.userDeposit(0);
    await reception.connect(user).userDeposit(0);

    const length = await reception.roomsLength();
    expect(length).to.eq(1);

    // room contract
    const roomAddress = await reception.roomAtIndex(0);
    const room = await ethers.getContractAt("Room", roomAddress);
    // decide winner
    await reception.decideWinner(0, user.address);
    // withdraw
    await room.withdraw();
    await room.connect(user).withdraw();
    const balance1 = await token.balanceOf(owner.address);
    const balance2 = await token.balanceOf(user.address);
    console.log(formatEther(balance1), formatEther(balance2));
  });
});
