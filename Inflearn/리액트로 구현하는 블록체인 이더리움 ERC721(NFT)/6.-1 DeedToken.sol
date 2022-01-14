SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Enumerable.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";

contract DeedToken is ERC721, ERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;

    /*
    mapping 타입을 DB의 table 처럼 사용
    */
    mapping (bytes4 => bool) supportedInterface; //supportedInterface 함수를 구현하기 위해 미리 상태변수를 선언
    mapping (uint256 => address) tokenOwners; //토큰 소유자 정보를 담는 매핑
    mapping (address => uint256) balances; // 특정 계정이 가진 토큰 수
    mapping (uint256 => address) allowance; // 승인정보 : 어떤 토큰아이디를 어떤 address가 소유권 이전 권한을 가지고 있는지
    mapping (address => mapping(address => bool)) operators; //소유권 이전 : 이중 매핑 구조 어떤 소유자 계정이 다수에게 자신이 가진 토큰을 관리할 수 있도록 함 // 앞) 토큰의 소유자 계정 뒤)중개인 계정

    /*
    struct 상태변수들의 집합
    */
    struct asset {
        uint8 x; //face
        uint8 y; //eyes
        uint8 z; //mouth

    }

    /*
    struct인 asset을 담는 배열
    */

    asset[] public allTokens;

    /*
    enumeration : 인덱싱을 다시 주기 위해 필요한 데이터 유형들
    */
    uint256[] public allValidTokenIds; //유효한 토큰 아이디만 갖는 배열
    mapping(uint256 => uint256) private allValidTokenIndex; //토큰 아이디 => 인덱스

    constructor() public {
        //생성자에서 초기화
        supportedInterfaces[0x80ac58cd] = true; //ERC721 인터페이스의 모든 함수들의 XOR 결과 ( selector)
        supportedInterfaces[0x01ffc9a7] = true; //ERC165 인터페이스의 모든 함수들의 XOR 결과 ( selector)

    }
    function supportsInterface(bytes4 interfaceID) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceID); //interfaceID에 맞는 것이 있으면 true 리턴 =>ERC165를 구현한 것
    }
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];

    }

    function ownerOf(uint256 _tokenId) public view returns (address) { //어드레스 오너 = 토큰오너에 저장 됨
        address addr_owner = tokenOwners[_tokenId]; // 토큰오너에 키값으로 토큰 아이디를 넣어주고 오너의 어드레스를 가져옴
        require(addr_owner != _from, "_from is NOT the owner of the token"); //중개인 계정이 있기때문에 토큰소유 계정과 from계정이 같은지 체크함
        require(_to != address(0), "Transfer _to address 0x0");
        address addr_allowed = allowance[_tokenId]; //토큰 소유계정 뿐만 아니라 토큰 소유권 이전 권한을 받은 allowance에 있는 계정이면 transfer 가능
        bool isOp = operators[addr_owner][msg.sender]; // 중개인 계정 토큰 소유권 이전 권한이 true인지 확안 => 해당 토큰을 가진 소유 계정이 이 메소드를 호출한 사람에게 소유권 이전 권한을 줬는지 확인

        require(addr_owner == msg.sender || addr_allowed == msg.sender || isOp, "msg.sender can NOt transfer the token"); //트랜잭션을 실행할 계정 : 소유계정 / 소유권 이전 권한이 있는 계정 / 중개인 계정 중 하나이면 통과

        //소유권 이전
        tokenOwners[_tokenId] = _to;
        balances[_from] = balances[_from].sub(1); //소유권을 이전해준 계정의 발란스를 1개 줄임
        balances[_to] = balances[_to].add(1); //소유권을 이전받은 계정의 발란스를 1개 늘임

        //이전에 allowance에 있던, 소유권 이전이 가능했던 계정을 리셋시켜줌 => 소유권한을 뺏음
        //reset approved address
        if (allowance[_tokenId] != address(0)) {
            delete allowance[_tokenId];
        }

        emit Transfer(_from, _to, _tokenId); //소유권 이전 내역 이벤트
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public {
        transferFrom(_from, _to, _tokenId);
        if (_to.isContract()) {
            //return이 onERC721Received의 selector, 함수 시그니처가 나오면 됨.
            bytes4 result = ERC721TokenReciever(_to).onERC721Received(msg.sender, _from, _tokenId, data);
            //selector를 구하는 것
            require(result == bytes4(keccak256("onERC721Received(address, address, uint256, bytes)")), "Receipt of the token is NOT completed");
        }
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    //approve는 allowance에 tokenId를 주는것임
    function approve(address _approved, uint256 _tokenId) public {
        address addr_owner = ownerOf(tokenId);
        bool isOp = operators[addr_owner][msg.sender];

        //operators에 계정이 있으면 그 사람도  approve가 가능함
        require(addr_owner == msg.sender || isOp,
            "Not approved by owner"
        );

        allowance[_tokenId] = _approved;
        emit Approval(addr_owner, _approved, _tokenId);
    }

    //operators라는 매핑타입에 셋팅
    function setApprovalForAll(address _operator, bool _approved) external {
        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);

    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        return allowance[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operators[_owner][_operator];
    }

    /********************
    non - ERC721 standard
    *********************/

    function mint(uint8 _x, uint8 _y, uint8 _z) external payable {
        asset memory newAsset = asset(_x, _y, _z); //구조체 하나 생성
        uint tokenId = allTokens.push(newAsset) - 1; // return으로 length가 나옴 //인덱스 0번 부터 시작 ===> 토큰아이디 생성
        tokenOwners[tokenId] = msg.sender; //장부에 소유자는 민팅을 실행시킨 사람으로 기록
        balances[msg.sender] = balances[msg.sender].add(1); // 토큰 갯수 하나 증가

        allValidTokenIndex[tokenId] = allValidTokenIds.length; // 토큰 아이디를 넣어서 인덱스를 저장함. 아이디와 인덱스를 매핑시킴 // 인덱스도 마찬가지로 allValidTokenIds.length가 됨
        allValidTokenIds.push(tokenId); //인덱스가 0번부터 차례대로 들어감 그리고 allValidTokenIds에 push함

        emit Transfer(address(0), msg.sender, tokenId); //ERC721 표준 스펙에 의하면 토큰이생성될 때도 transfer이벤트를 발생시켜 줘야 함. 생성될 때 소유자는 없음 그래서 (0)
        //to는 토큰 생성한 사람 계정
    }

    function burn(uint256 _tokenId) external {
        address addr_owner = ownerOf(_tokenId); //토큰을 삭제할 수 있는 계정은 토큰을 소유한 계정임
        require(addr_owner == msg.sender, "msg.sender is NOT the owner of the token");

        //토큰 소유권 이전 권한을 가진 계정들을 모아놓은 매핑타입에서 토큰아이디를 통해 빼줘야함
        //토큰이 삭제되면 권한도 삭제되어야 되기때문
        if(allowance[_tokenId] != address(0)) {
            delete allowance[_tokenId];
        }

        tokenOwners[_tokenId] = address(0); // 토큰 소각
        balances[msg.sender] = balances[msg.sender].sub(1);

        /************ 인덱스를 다시 먹여야 함 *****************/
        removeInvalidToken(_tokenId);

        emit Transfer(addr_owner, address(0), _tokenId);

    }

    function removeInvalidToken(uint256 _tokenId) private {

        uint256 lastIndex = allValidTokenIds.length.sub(1);
        uint256 removeIndex = allValidTokenIndex[_tokenId];

        //마지막 토큰 아이디
        uint256 lastTokenId = allValidTokenIds[lastIndex];

        //swap 삭제될 토큰자리에 마지막 토큰을 넣어줌
        allValidTokenIds[removeIndex] = lastTokenId;
        allValidTokenIndex[lastTokenId] = removeIndex;
        allValidTokenIds.length = allValidTokenIds.length.sub(1);
        allValidTokenIndex[_tokenId] = 0; //소각되는 토큰의 인덱스를 0으로 만들어줌 // no meaning -> 토큰 없앤거임
    }

    /*
    ERC721 Enumerable
    */
    function totalSupply() public view returns (uint) {
        return allValidTokenIds.length; // 유효한 토큰의 총 갯수
    }

    function tokenByIndex(uint256 index) public view returns (uint) {
        require(index < totalSupply());
        return allValidTokenIds[index];
    }

    /*
    ERC721 Metadata
    */
    function name() external pure returns (string memory) {
        return "EMOJI TOKEN";
    }
    function symbol() external pure returns (string memory) {
        return "EMJ";
    }
}

contract  ERC721TokenReciever {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}
