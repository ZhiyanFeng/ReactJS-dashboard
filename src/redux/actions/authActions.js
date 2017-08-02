import axios from 'axios';
import { SET_SEARCH_USERS, SET_ADMIN_USER } from './actionTypes/allActionTypes';
import setAuthorizationToken from '../utils/setAuthorizationToken';
import Constants from '../../api/constants'; //API_SERVER_URL or TEST_SERVER_URL
//:%s/API_SERVER_URL/TEST_SERVER_URL/gc
//:%s/TEST_SERVER_URL/API_SERVER_URL/gc


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
        localStorage.removeItem('key');
        localStorage.removeItem('admin');
        dispatch(setAdminUser({}));
    }
}

export function login(data) {
    return dispatch => {
        const config = {
            headers: {
                'Content-Type': 'application/json'
            }
        }
        return axios.post(`${Constants.TEST_SERVER_URL}/sessions`, {'email': data.email, 'password': data.password}, config).then(res => {
            if(res.data.eXpresso.code === -1)
            {
                return res.data.eXpresso;
            }else{
                localStorage.setItem('admin', res.data.eXpresso.first_name);
                localStorage.setItem('key', res.data.eXpresso.api_key);
                return res.data.eXpresso;
            }
        });
    }
}
