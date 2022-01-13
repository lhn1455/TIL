# Iterator Pattern (반복자 패턴)
> 컬렉션 구현 방법을 노출시키지 않으면서도 그 집합체 안에 들어있는 모든 항목에 접근할 수 있는 방법을 제공   
=> 무엇인가 많이 모여 있는 것들을 순서대로 지정하면서 전체를 검색하는 처리를 실행하기 위한 패턴   


## for문의 경우
Java 언어에서 배열 arr의 모든 요소를 표시하기 위해서는 아래처럼 코드를 작성할 수 있음
```Java
for (int i = 0; i < arr.length < i++ ) {
    System.out.println(arr[i]);
}
```
- "무엇인가 많이 모여 있는 것들" : arr배열
- "순서대로 지정하면서 전체를 검색" : i 변수

i 변수의 기능   
1. 배열의 위치를 나타냄
2. 값을 증가/감소 시켜 배열의 전체를 검색할 수 있도록 도와줌


## => 이러한 기능을 **추상화**하여 일반화 한 것을 Iterator(반복자) 패턴이라고 부름

<br/>
<br/>

<hr>

<br>
<br>

# 예제
- 요구사항
    - 책(Book)을 관리해주는 서가(BookShelf)의 기능
        -  관리기능
            1. 서가(BookShelf)에 책(Book)을 넣을 수 있다.
            2. 서가(BookShelf) 내부에 있는 모든 책(Book)을 순서대로 검색 혹은 표시 할 수 있다.
        - 제약 조건
            1. for loop 같은 반복문을 통해 배열에 직접 접근하지 않는다.
            2. Java에서 기존에 제공하는 Iterator를 사용하지 않는다.

- 이름과 역할

| <center>이름</center> | <center>역할</center> |   
|---|---|
| Aggreate | 집합체를 나타내는 인터페이스 |
| Iterator | 하나씩 나열하면서 검색을 실행하는 인터페이스 |
| Book | 책을 나타내는 클래스 |
| BookShelf | 서가를 나타내는 클래스 |
| BookShelfIterator | 서가를 검색하는 클래스 |
| Main | 테스트 클래스 |

<br>

>상속구조

![Iterator_Inheritance](/JAVA/DesignPattern/Img/Iterator.png)

<br>

>Aggregate(집합체) 인터페이스
```java
public interface Aggregate {
    public abstract Iterator iterator();
}
```
Aggregate 인터페이스를 통해 Iterator가 주어진 역할을 할 수 있도록 만들어줌 (API 역할)

<br>


> Iterator 인터페이스
```java
public interface Iterator {
    public abstract boolean hasNext();
    public abstract Object next();
}
```
실제 요소를 순서대로 접근할 수 있는 메서드를 가지고 있는 인터페이스   
해당 인터페이스는 2개의 메서드를 가지고 있으며, 각각의 역할은 다음 요소가 존재하는 지 확인하는 hasNext()메서드와 다음 요소를 가져오는 next()로 구성되어 있음. next()는 다음 요소를 가져올 수 있을 뿐 아니라 다음 요소로 이동하는 역할도 함께 수행(for loop "i++"역할)

<br>


> Book 클래스
```java
public class Book {
    private String name;

    public Book(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }
}
```
Book 클래스는 책을 나타내는 클래스. getName()메서드를 통해 책 이름을 제공함

<br>


>BookShelf 클래스
```java
public class BookShelf implements Aggregate {
    private Book[] books;
    private int last = 0;

    public BookShelf(int maxSize) {
        this.blooks = new Book[masSize];
    }

    public Book getBookAt(int index) {
        return book[index];
    }

    public void appendBook(Book book) {
        this.books[last] = book;
    }

    public int getLength() {
        return last;
    }

    public Iterator iterator() {
        return new BookShelfIterator(this);
    } 
}
```
Aggregate 인터페이스를 상속받은 걸로 보아 Aggregate 인터페이스에서 정의한 Iterator 기능을 가지고 있는 클래스임을 알 수 있음. 하지만 next(), hasNext()의 구체적인 기능은 보이지 않음. 단지 BookShelfIterator 클래스를 생성하고 있음

<br>


> BookShelfIterator 클래스
```java
public class BookShelfIterator implements Iterator {
    private BookShelf bookShelf;
    private int index;

    public BookShelfIterator(BookShelf bookshelf) {
        thks.bookShelf = bookShelf;
    }

    public boolean hasNext() {
        if (index < bookShelf.getLength()) {
            return true;
        }
        return false;
    }

    public Object next() {
        Book book = bookShelf.getBook(index);
        ++index;
        return book;
    }
}
```
Iterator의 구현부가 있는 클래스   
hasNext()메서드와 next()메서드가 구현되어 있음. next() 메서드애는 다음 요소와 이동 모두 포함되어 있다는 것도 알 수 있음

<br>


> main 클래스
```Java
public class Main {
    public static void main(String[] args) {
        BookShelf bookShelf = new BookShelf(4);
        bookShelf.appendBook(new Book("Around the world in 80days"));
        bookShelf.appendBook(new Book("Bible"));
        bookShelf.appendBook(new Book("Cinderella"));
        bookShelf.appendBook(new Book("Daddy-long-legs"));

        Iterator it = bookShelf.iterator();

        while(it.hasNest()) {
            Book book = (Book) it.next();
            System.out.println(book.getName());
        }
    }
}
```
Main클래스에서 `Iterator it = bookShelf.iterator();` 여기서 Iterator를 씀. BookShelfIterator 클래스에 대한 언급조차 없지만 앞서 만든 `BookShelf`클래스에서 맨밑에 `new BookShelfIterator();`를 통해 이미 객체를 생성했기 때문에 여기서는 그냥 가져다가 씀. main클래스는 `BookShelfIterator`의 존재를 전혀 알지 못하지만 `Iterator`를 사용하는데 아무 문제가 없음.

##Q. for문 보다 복잡한 걸 왜 쓸까?
- 내부 구현을 노출 시키지 않고 집약(집합) 객체(배열과 같은)에 접근하고 싶은 경우
- 집약(집합) 객체에 다양한 탐색 경로가 필요한 경우 (Iterator 인터페이스 상속 구조) 역방향 탐색, 특정 인덱스 탐색 등
- 서로 다른 집합 객체 구조에 대해서도 동일한 방법으로 접근하고 싶은 경우 ArrayList, LinkedList와 같은 다른 자료 구조에서도 동일한 방법 사용 가능   
<br>
<br>


> ### *위 예제의 경우, 서가관리에서 변화가 집중될 수 있는 **BookShelf클래스**와 **반복문**을 분리함으로 반복문 재사용 효과를 노려본 패턴*