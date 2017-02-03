import {
    GET_USERS,
    DELETE_USER,
    EDIT_USER,

} from './actionTypes/allActionTypes';

export function getUsers(result){
    return{
        type: 'GET_USERS',
        payload: result
    }
}
