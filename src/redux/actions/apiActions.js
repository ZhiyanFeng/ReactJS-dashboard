import axios from 'axios';
import { SET_SEARCH_USERS, SET_ADMIN_USER, SET_SEARCH_LOCATIONS, SET_ACTIVE_USER} from './actionTypes/allActionTypes';
import setAuthorizationToken from '../utils/setAuthorizationToken';
import Constants from '../../api/constants';

export function setSearchUsers(users) {
    return {
        type: SET_SEARCH_USERS,
        users
    };
}

export function setSearchLocations(locations) {
    return {
        type: SET_SEARCH_LOCATIONS,
        locations
    };
}
export function setActiveUser(activeUser) {
    return {
        type: SET_ACTIVE_USER,
        activeUser
    };
}

export function searchUsers(query, admin){
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
        return axios.post(`${Constants.API_SERVER_URL}/api/users/search`, {'user_name': query}, config).then(res => {
            dispatch(setSearchUsers(res.data.eXpresso));
        });
    }
}

export function searchUserDetail(id, admin){
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
        return axios.get(`${Constants.API_SERVER_URL}/api/users/${id}/user_detail`, config).then(res => {
            dispatch(setActiveUser(res.data.eXpresso));
        });
    }
}

export function searchLocations(query, admin){
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
        return axios.post(`${Constants.API_SERVER_URL}/api/locations/search`, {'location_query': query}, config).then(res => {
            dispatch(setSearchLocations(res.data.eXpresso));
        });
    }
}
