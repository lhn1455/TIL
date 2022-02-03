# 2.1 Before React
> 브라우저만 이용한 간단한 앱 만들기를 통해 VanillaJS vs ReactJS 비교하기
- 로직 : 버튼을 만든 후 버튼을 누를때 마다 클릭 수가 올라가는 앱

<br>
<br>
<br>

### 기본 템플릿
```js
<!DOCTYPE html>
<html>
    <body></body>
    <script></script>
</html> 
```

## VanillaJS

1. 버튼 만들기   
    - 버튼 만들기   
    ```js
    <body>
        <button id="btn">Click me</button>
    </body>
    ```
    - Javascript에서 button 가져오기   
    ```js
    <script>
    const button = document.getElementById("btn")
    </script>
    ```
    - Click Event 감지하기
    ```js
    <script>
    const button = document.getElementById("btn")
    button.addEventListener("click");
    </script>
    ```
    - function 만들기
    ```js
    function handleClick() {
            console.log("I have been clicked")
            counter = counter + 1;
            span.innerText = `Total clicks : ${counter}`;
        }
    ```
    - Click Event 수정
    ```js
    button.addEventListener("click", handleClick);
    ```

2. 클릭 갯수 세기
    - 텍스트 만들기
    ```js
    <script>
    <span>Total clicks : 0</span>
    </script>
    ```
    - 카운터 만들기
    ```js
    <script>
        let counter = 0;
        function handleClick() {
            counter = counter + 1;
        }
    </script>
    ```
    → counter 데이터가 바뀌어도 HTML에 반영되지 않음
    - Javascript에서 span을 가져옴
    ```js
    const span = document.querySelector("span")
    ```
    - 데이터 수정
    ```js
    <script>
        let counter = 0;
        function handleClick() {
            counter = counter + 1;
            span.innerText = counter ;
        }
    </script>
    ```
    - 이전 텍스트 기억하도록 만들기
    ```js
    span.innerText = `Total clicks : ${counter}`;
    ```

## 요약
> 1. HTML 작성
```js
<body>
    <span>Total clicks : 0</span>
    <button id="btn">Click me</button>
</body>
```
> 2. Javascript에서 가져오기
```js
<script>
    const span = document.querySelector("span")
    const button = document.getElementById("btn")
</script>
```
> 3. Event 감지하기
```js
<script>
    button.addEventListener("click", handleClick);
</script>
```
> 4. 데이터 업데이트
```js
    counter = counter + 1;
```
> 5. HTML 업데이트
```js
    span.innerText = `Total clicks : ${counter}`;
```

## 💻 전체 코드 - [Vanilla.html]()

<br>
<br>
<br>

## ReactJS







<script src="https://unpkg.com/react@17.0.2/umd/react.production.min.js"></script>
<script src="https://unpkg.com/react-dom@17.0.2/umd/react-dom.production.min.js"></script>