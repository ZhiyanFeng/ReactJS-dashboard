'use strict';exports.__esModule=true;exports.login=login;var _axios=require('axios');var _axios2=_interopRequireDefault(_axios);function _interopRequireDefault(obj){return obj&&obj.__esModule?obj:{default:obj};}//import jwtDecode from 'jwt-decode';
//import { SET_CURRENT_USER } from './types';
//
//export function setCurrentUser(user) {
//  return {
//    type: SET_CURRENT_USER,
//    user
//  };
//}
//
//export function logout() {
//  return dispatch => {
//    localStorage.removeItem('jwtToken');
//    setAuthorizationToken(false);
//    dispatch(setCurrentUser({}));
//  }
//}
function login(data){return function(dispatch){return _axios2.default.post('/api/auth',data);//     .then(res => {
// const token = res.data.token;
// localStorage.setItem('jwtToken', token);
// setAuthorizationToken(token);
// dispatch(setCurrentUser(jwtDecode(token)));
//});
};};var _temp=function(){if(typeof __REACT_HOT_LOADER__==='undefined'){return;}__REACT_HOT_LOADER__.register(login,'login','src/redux/actions/authActions.js');}();;