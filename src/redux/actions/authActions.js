import axios from 'axios';
import { SET_SEARCH_USERS, SET_ADMIN_USER } from './actionTypes/allActionTypes';
import setAuthorizationToken from '../utils/setAuthorizationToken';

export function setAdminUser(admin) {
  return {
    type: SET_ADMIN_USER,
    admin
  };
}

export function setSearchUser(users) {
    return {
        type: SET_SEARCH_USERS,
        users
    };
}

export function logout() {
    return (dispatch) => {
        localStorage.removeItem('jwtToken');
        setAuthorizationToken(false);
        dispatch(setCurrentUser({}));
    }
}

export function login(data) {
    return dispatch => {
        const config = {
            headers: {
                'Content-Type': 'application/json'
            }
        }
        return axios.post('http://localhost:3000/sessions', {'email': data.email, 'password': data.password}, config).then(res => {
            localStorage.setItem('admin', res.data.eXpresso.first_name);
            localStorage.setItem('key', res.data.eXpresso.api_key);

            dispatch(setAdminUser(res.data.eXpresso));
        });
    }
}
