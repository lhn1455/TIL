# 메뉴 구성 (react-router)

> 추가 설치
```terminal
cd app
npm install react-router
npm install react-router-dom
npm install react-router-redux
npm install react-bootstrap
```
> ## 설치 확인   

![package.json](/Inflearn/img/package_json.png)

>## main   

![main](/Inflearn/img/main.png)

<br>

<hr>
<br>

# 시작하기
>## store.js   

```javascript
import createHistory from "history/createBrowserHistory";
import { createStore, applyMiddleware, compose } from 'redux'
import { routerMiddleware } from 'react-router-redux'
import createSagaMiddleware from "redux-saga";
import { generateContractsInitialState } from 'drizzle'

import drizzleOptions from "/drizzleOptions";
import reducer from './reducer'
import rootSaga from './rootSaga'

const history = createHistory()
const routingMiddleware = routerMiddleware(history)
const sagaMiddleware = createSagaMiddleware()

const initialState = {
    contract: generateContractsInitialState(drizzleOptions0)
}

const store = createStore(
    reducer, 
    initialState,
    compose(
        applyMiddleware(
            routingMiddleware,
            sagaMiddleware 
        )
    )
)

sagaMiddleware.run(rootSaga)
export { history } //history

export default store
```
-> history 를 쓴 이유? react-router를 쓰기 위해   
<br>
<br>


> ## App.js
> - export된 history를 import
> - react-router를 import
```javascript
import React, { Component } from "react";
import { DrizzleProvider } from "drizzle-react";
import { LoadingContainer } from "drizzle-react-components";
import { Router } from 'react-router'; //추가

import "./App.css";
import drizzleOptions from "./drizzleOptions";
import store, {history} from "./store"; //추가
import MainContainer from "./MainContainer";

class App extends Component {
    render() {
        return (
            <DrizzleProvider options={drizzleOptions} store={store}>
                <LoadingContainer>
                    <Router history={history}> 
                        <Home/>
                    </Router>
                </LoadingContainer>
            </DrizzleProvider>

        );
    }
}

export default App;
```
- < Router history={history} > : history속성을 전달하기 위해 store.js에서 export해준 history를 넣어줌   
- < Home /> : 메뉴 구성을 하는 컴포넌트

<br>
<br>

> ## Home.js (Menu-header)
```javascript
import React, { Component } from 'react'
import { Route } from 'react-router'
import { Link } from 'react-router-dom'

import { issue, tokens } from './images'
import logo from './logo.png'

class Home extends Component {
    render() {
        return (
            <div>
                <div className="Menu-header">
                    <Link to={"/"}><img src={logo} className="App-logo" alt="logo"/></Link>
                    <Link to={"/issue"}><img src={issue} className="Menu-item" alt="issue"/></Link>
                    <Link to={"/tokens"}><img src={tokens} className="Menu-item" alt="tokens"/></Link>
                </div>

                <Route exact path={"/"} component={MainContainer}/>
                <Route path={"/issue"} component={IssueContainer}/>
                <Route path={"/tokens"} component={HomeToken}/>
                
            </div>
        );
    }
}

export default Home
```
- Link to : href와 같은 역할. 이미지를 클릭했을 때, to로 지정된 곳으로 이동
- Route : component의 경로를 지정하고 연결시켜줌 (java-controller에서 Getmapping("/main")과 같은 느낌)


