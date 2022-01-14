# 1. reducer
- 사용자의 `reducer `추가 (reducer : 새로운 상태 생성)
``` javascript
<DrizzleProvider options={drizzleOptions} store={store}> // store를 새로 생성하여 DrizzleProvider에 전달해야 함
    <LoadingContainer>
        <MainContainer />
    </LoadingContainer>
</DrizzleProvider>
```

## > store를 새로 생성하는 방법   
```javascript
const store = createStore(
    reducer, //생성할때 reducer 전달 이때 사용자가 만든 reducer 같이 전달해야함 (아래코드)
    initialState,
    compose(
        applyMiddleware,
            thunkMiddleware,
            routingMiddleware,
            sagaMiddleware
        )
    )
)
```
> reducer가 하나 이상일 때 , `redux`에서 제공하는 `combinReducers` 사용
```javascript
const reducer = combinReducers({
    customReducer: customReducer, //사용자 정의
    routing: routerReducer, //기본
    ....drizzleReducers     //기본
})

export default reducer
```

>> 이러한 작업은 drizzle-box를 쓰는것과 관계 없이 리액트 redux와 미들웨어를 사용하게 되면 반드시 해줘야하는 작업

<br>
<br>

# 2. redux-saga
- 비동기적인 처리를 위해 사용하는 라이브러리
- drizzle에서는 이더리움과의 통신을 위해 사용   

        `-- drizzle@1.2.4   
            `-- redux-saga@0.16.2

### `action` -> `middleware` -> `reducer` -> `store(애플리케이션 상태저장소)`

middleware : redux-saga (drizzle에서는 이것을 사용)
> middleware는 action과 reducer사이에서 뭔가 다른 작업을 할 때 사용하는 함수들.   
 상태를 업데이트 하기 위해 reducer를 통해 액션을 store에 전달하게됨.   
 예) 서버에 뭔가 요청을 보내고 응답을 받은 후에 추가적인 로직을 적용할 경우 특히 비동기적인 처리를 위해 (결과를 받은 후에 다음 스텝으로 넘어가야 할 때) 미들웨어를 활용함. 

<br>

### dizzle이 내부적으로 동작하는 방법   

![redux-saga](/Inflearn/img/redux-saga.png)
- cacheCall() : 내부적으로 액션을 디스패치함.(`'CALL_CONTRACT_FN'`이라는 타입의 액션을 디스패치함)
<br>

    -----redux-saga-----
- yield takeEvery: 액션이 디스패치 될 때 마다 `callCallContractFn`을 호출하도록 되어 있음
- yield call : 컨트랙트의 해당 함수를 호출함. 비동기라서 결과를 기다림 (const callResult)
- yield put : 결과가 오면 새로운 액션을 디스패치 - react-saga에서 제공하는 API , `GOT_CONTRACT_VAR`타입의 액션을 디스패치 하면 reducer에 전달   

    -----reducer-----
- action.name: 해당 컨트랙트 상태를 업데이트

> - yield takeEvery : (saga helper) 모든 action을 watch하여 비동기 처리   
    *yield takeEvery('CALL_CONTRACT_FN', callCallContractFn)*   
> - yield call : 함수 호출 - 컨트랙트 함수 비동기 호출   
    *yield call(txObject.call, callArgs)*
> - yield put : action을 dispatch   
    *yield put ({ type : 'GOT_CONTRACT_VAR', ...dispatchArgs })*
