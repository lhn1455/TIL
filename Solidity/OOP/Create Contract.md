# 계약 생성하기

계약을 생성하고 사용할 수 있는 방법
1. `new`키워드 사용하기
2. 이미 배포된 계약의 주소를 사용
<hr>

##  1. `new`키워드 사용하기
- 솔리디티에서 `new`키워드는 새로운 계약 인스턴스를 배포 및 생성한다.
- 그것은 계약을 배포, 상태변수를 초기화, 생성자를 실행, 논스 값을 1로 설정하고 최종적으로는 인스턴스의 주소를 호출자에게 반환함으로써 계약 인스턴스를 초기화 한다.
- 계약을 배포하는 것에는 요청과 함께 배포를 완료하기에 충분한 가스가 제공되었는지 확인하고, 요청자의 주소와 논스 값을 가지고 계약 배포를 위한 새로운 계정과 주소를 생성하고, 함께 보내진 이더를 전달하는 일이 포함된다.

다음 코드에는 `HelloWorld`와 `client` 계약이 정의 됐다.   
이 시나리오에서는 먼저 배포된 `client`계약이 `new`키워드를 사용해 `HelloWorld`계약의 인스턴스를 생성한다.   
```solidity
HelloWorld myObj = new HelloWorld();
```

다음 예제 코드를 보자
```solidity
pragma solidity ^0.4.19;

contract HelloWorld {
    uint private simpleInt;
    
    function getValue() public view returns (uint) {
        return simpleInt;
    }
    
    function setValue(uint _value) public {
        simpleInt = _value;
    }
}

contract client {
    //new 키워드 사용
    function useNewKeyword() public returns (uint) {
        HelloWorld myObj = new HelloWorld(); 
        
        myObj.setValue(10);
        
        return myObj.getValue();
    }
}
```

## 2. 계약의 주소 사용하기
- 계약이 이미 배포 및 초기화돼 있을 때는 이 방법으로 계약 인스턴스를 생성한다.
- 이 방법으로 계약을 생성하면 기존에 배포된 계약의 주소를 사용한다.
- 새로운 인스턴스가 생성되지 않고, 기존 인스턴스가 재사용된다.
- 기존 계약에 대한 참조는 그것의 주소를 사용해 이루어진다.

다음 예제 코드에는 두 건의 계약, `HelloWorld`와 `client`가 정의됐다.   
이 시나리오에서 `client`계약은 `HelloWorld` 계약의 알려진 주소를 사용해 그것에 대한 참조를 생성한다.   
`address`자료형을 사용해 주소를 `HelloWorld`계약 타입으로 변환하는 것이다.

다음 코드에서 `myObj`객체는 기존 계약의 주소를 갖고 있다.
```solidity
HelloWorld myObj = HelloWorld(obj);

```
다음 예제 코드를 보자
```solidity
pragma solidity ^0.4.19;

contract HelloWorld {
    uint private simpleInt;

    function getValue() public view returns (uint) {
        return simpleInt;
    }

    function setValue(uint _value) public {
        simpleInt = _value;
    }
}

contract client {
    address obj;
    
    function setObject(address _obj) external {
        obj = _obj;
    }
    
    //계약의 주소 사용
    function useExistingAddress() public returns (uint) {
        HelloWorld myObj = new HelloWorld(obj);

        myObj.setValue(10);

        return myObj.getValue();
    }
}
```
