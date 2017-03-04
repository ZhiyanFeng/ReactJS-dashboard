import { SET_ADMIN_USER } from '../actions/actionTypes/allActionTypes';
import isEmpty from 'lodash/isEmpty';

const initialState = {
  isAuthenticated: false,
  admin: {}
};

const authReducer = (state = initialState, action = {}) => {
  switch(action.type) {
    case SET_ADMIN_USER:
      return {
        isAuthenticated: !isEmpty(action.user),
        admin: action.admin
      };
    default: return state;
  }
}

module.exports = {
    authReducer,
}
