import { createStore } from 'redux';

function checkStorage() {
    if(localStorage.getItem('authToken'))
        return false;
    else
        return false;
}

const INITIAL_STATE = {
    logged: checkStorage(),
    user: {},
    participantId: null,
}

function reducer(state = INITIAL_STATE, action) {
    console.log(action);

    if(action.type === 'TOGGLE_LOGIN' || action.type === 'TOGGLE_LOGOUT') {
        console.log('LOGADO',{...state,
            logged: action.isLogged,
            user: action.user})
        return { 
            ...state,
            logged: action.isLogged,
            user: action.user
        }
    }

    if(action.type === 'STORE_USER') {
        return {
            ...state,
            user: action
        }
    }

    if(action.type === 'STORE_PARTICIPANT_ID') {
        return {
            ...state,
            participantId: action.participantId
        }
    }

    return state;
}

const store = createStore(reducer);

export default store;