//Variables
//// fundKeeper
//// int256 totalMintedPiamon 
//// mapping(BlindBoxId => uint256[])

//Struct (BlindBox)
//// import from PiamonUtils.sol
//// mapping(id => BlindBox)

//Struct (PiamonBox)
//// import from PiamonUtils.sol
//// mapping(BlindBoxId => PiamonBox[])

//Function addBlindBox (...)

//Funcion addPiamonBox(blindBoxId, ....piamon_data)

//Function Mint NFT param (receiverAddress, BlindBoxId, tokenURI) payable
//// import from Piamon.sol
//// check if value of payment is enough
//// transfer fund to fundKeeper
//// mint(receiverAddress, tokenURI)
