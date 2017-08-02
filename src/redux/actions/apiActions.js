import axios from 'axios';
import { SET_SEARCH_ADMIN_CLAIM, SET_REGION_CHANNEL, SET_CHANNEL_FOR_USER, SET_STORE_EMPLOYEES, SET_LOCATION_DETAIL,SET_SEARCH_USERS} from './actionTypes/allActionTypes';
import { SET_ADMIN_USER, SET_SEARCH_LOCATIONS, SET_ACTIVE_USER, SET_ACTIVE_USER_LATEST_CONTENTS, SET_DASHBOARD_DATA } from './actionTypes/allActionTypes';
import setAuthorizationToken from '../utils/setAuthorizationToken';
import Constants from '../../api/constants'; //API_SERVER_URL or TEST_SERVER_URL
//:
//:%s/TEST_SERVER_URL/API_SERVER_URL/gc

export function setSearchUsers(users) {
    return {
        type: SET_SEARCH_USERS,
        users
    };
}
export function setSearchAdminClaim(info) {
    return {
        type: SET_SEARCH_ADMIN_CLAIM,
        info
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

export function setChannelForUser(channel) {
    return {
        type: SET_CHANNEL_FOR_USER,
        channel
    };
}

export function setRegionChannel(channels) {
    return {
        type: SET_REGION_CHANNEL,
        channels
    };
}
export function setLocationDetail(locationDetail) {
    return {
        type: SET_LOCATION_DETAIL,
        locationDetail
    };
}

export function setStoreEmployees(storeEmployees) {
    return {
        type: SET_STORE_EMPLOYEES,
        storeEmployees
    };
}
export function setActiveUserLatestContents(activeUserLatestContents) {
    return {
        type: SET_ACTIVE_USER_LATEST_CONTENTS,
        activeUserLatestContents
    };
}
export function setDashboardData(dashboardData) {
    return {
        type: SET_DASHBOARD_DATA,
        dashboardData
    };
}

export function setDeleteUsers(userId) {
    return {
        type: 'user.delete',
        id: userId,
    };
}

export function deleteUser(userId, admin){
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
        return axios.get(`${Constants.TEST_SERVER_URL}/api/users/${userId}/deleteUser`, config).then(res => {
            dispatch(setDeleteUsers(userId));
        });
    }
}

export function removeUserFromLocation(locationId, userId, admin){
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
        return axios.post(`${Constants.TEST_SERVER_URL}/api/users/remove_from_location`,{'location_id': locationId, 'id': userId }, config).then(res => {
        });
    }
}

export function removeUserFromChannel(channelId, userId, admin){
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
        return axios.post(`${Constants.TEST_SERVER_URL}/api/users/remove_from_channel`,{'channel_id': channelId, 'id': userId }, config).then(res => {
        });
    }
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
        return axios.post(`${Constants.TEST_SERVER_URL}/api/users/search`, {'user_name': query}, config).then(res => {
            dispatch(setSearchUsers(res.data.eXpresso));
        });
    }
}

export function updateUser(id, params, admin){
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
        return axios.post(`${Constants.TEST_SERVER_URL}/api/users/${id}/update_user`, params, config).then(res => {
            return res;
        });
    }
}

export function pushSNS(id, params, admin){
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
        return axios.post(`${Constants.TEST_SERVER_URL}/api/users/${id}/sns_push`, params, config).then(res => {
            return res;
        });
    }
}

export function updateLocation(id, params, admin){
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
        return axios.post(`${Constants.TEST_SERVER_URL}/api/locations/${id}/update_location`, params, config).then(res => {
            return res;
        });
    }
}
// for admin claim request
export function searchAdminClaim(claim_id, admin){
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
        return axios.get(`${Constants.TEST_SERVER_URL}/api/admin_claims/${claim_id}/display`, config).then(res => {
            dispatch(setSearchAdminClaim(res.data));
        });
    }
}

export function allowClaim(email, userId, locationId, admin){
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
        return axios.post(`${Constants.TEST_SERVER_URL}/api/admin_claims/allowClaim`, {'email': email, 'userId': userId, 'locationId': locationId}, config).then(res => {
            return res;
        });
    }
}

export function addToChannel(user_id, query, admin){
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
        return axios.post(`${Constants.TEST_SERVER_URL}/api/users/${user_id}/create_subscription`, {'user_id': user_id, 'channel_id':query.channel_id, 'is_coffee': query.is_coffee, 'is_invisible': query.is_invisible}, config).then(res => {
            return res.data;
        });
    }
}

export function sendEmail(email, admin){
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
        return axios.post(`${Constants.TEST_SERVER_URL}/api/admin_claims/sendEmail`, {'email': email}, config).then(res => {
            return res;
        });
    }
}

export function searchUserLatestContent(id, admin){
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
        return axios.get(`${Constants.TEST_SERVER_URL}/api/users/${id}/latest_contents`, config).then(res => {
            dispatch(setActiveUserLatestContents(res.data.eXpresso));
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
        return axios.get(`${Constants.TEST_SERVER_URL}/api/users/${id}/details`, config).then(res => {
            dispatch(setActiveUser(res.data.eXpresso));
        });
    }
}

export function searchLocationDetail(id, admin){
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
        return axios.get(`${Constants.TEST_SERVER_URL}/api/locations/${id}/details`, config).then(res => {
            dispatch(setLocationDetail(res.data.eXpresso));
        });
    }
}

export function searchStoreEmployees(id, admin){
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
        return axios.get(`${Constants.TEST_SERVER_URL}/api/locations/${id}/member_list`, config).then(res => {
            dispatch(setStoreEmployees(res.data.eXpresso));
        });
    }
}

export function searchWorkLocations(user_id, admin){
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
        return axios.get(`${Constants.TEST_SERVER_URL}/api/users/${user_id}/location_list`, config).then(res => {
            return res.data.eXpresso;
        });
    }
}

export function searchChannelForUser(id, admin){
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
        return axios.get(`${Constants.TEST_SERVER_URL}/api/users/${id}/subscriptions`, config).then(res => {
            dispatch(setChannelForUser(res.data.eXpresso));
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
        return axios.post(`${Constants.TEST_SERVER_URL}/api/locations/search`, {'location_query': query}, config).then(res => {
            dispatch(setSearchLocations(res.data.eXpresso));
        });
    }
}

export function searchRegionChannel(admin){
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
        return axios.get(`${Constants.TEST_SERVER_URL}/api/channels/list_region`, config).then(res => {
            dispatch(setRegionChannel(res.data.eXpresso));
        });
    }
}

export function createLocation(query, admin){
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
        return axios.post(`${Constants.TEST_SERVER_URL}/api/locations/create`, {'LocationName': query.location_name, 'FormattedAddress': query.formatted_address}, config).then(res => {
            return res.data.eXpresso;
        });
    }
}

export function updateUserApiCall(operation, id, query, key){
    return dispatch => {
        const config = {
            headers: {
                'X-Method': 'pass_verification',
                'Session-Token': '1333',
                'Accept': 'application/vnd.Expresso.v1',
                'Authorization': `Token token=${key}, nonce="def"`,
                'Content-Type': 'application/json'
            }
        }
        if(operation === 'phone'){
            return axios.post(`${Constants.TEST_SERVER_URL}/api/users/${id}/update_user`, {'phone_number': query}, config).then(res => {
                //dispatch(setSearchUsers(res.data.eXpresso));
            });
        }
        if(operation === 'firstname'){
            return axios.post(`${Constants.TEST_SERVER_URL}/api/users/${id}/update_user`, {'first_name': query}, config).then(res => {
                //dispatch(setSearchUsers(res.data.eXpresso));
            });
        }
        if(operation === 'lastname'){
            return axios.post(`${Constants.TEST_SERVER_URL}/api/users/${id}/update_user`, {'last_name': query}, config).then(res => {
                //dispatch(setSearchUsers(res.data.eXpresso));
            });
        }
    }
}

export function fetchDashboardData(query, admin){
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
        return axios.post(`${Constants.TEST_SERVER_URL}/api/analytics/new_registration_data`, {'number_of_days': query}, config).then(res => {
            dispatch(setDashboardData(res.data.eXpresso));
        });
    }
}
