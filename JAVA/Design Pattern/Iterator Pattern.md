# Iterator Pattern (반복자 패턴)
> 컬렉션 구현 방법을 노출시키지 않으면서도 그 집합체 안에 들어있는 모든 항목에 접근할 수 있는 방법을 제공   

컬렉션 객체 안에 들어있는 모든 항목에 일일이 접근하는 작업을 컬렉션 객체가 아닌 반복자 객체에서 맡게됨. 이렇게 하면 집합체의 인터페이스 및 구현이 간단해질 뿐 아니라, 집합체에서는 반복작업에 손을 떼고 원래 자신이 할 일에만 전념할 수 있음
