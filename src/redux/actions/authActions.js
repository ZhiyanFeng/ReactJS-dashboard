import axios from 'axios';
import jwtDecode from 'jwt-decode';
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

export function search(query, admin){
    return dispatch => {
        const config = {
            headers: {
                'X-Method': 'pass_verification',
                'Session-Token': '1333',
                'Accept': 'application/vnd.Expresso.v1',
                'Authorization': `Token token=${admin}, nonce="def"`,
                'Content-Type': 'application/json'
            }
        }
        return axios.post('http://localhost:3000/api/users/search', {'user_name': query}, config).then(res => {
            dispatch(setSearchUser(res.data.eXpresso));
        });
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
