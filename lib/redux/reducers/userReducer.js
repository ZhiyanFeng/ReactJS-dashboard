"use strict";var _stringify=require("babel-runtime/core-js/json/stringify");var _stringify2=_interopRequireDefault(_stringify);var _from=require("babel-runtime/core-js/array/from");var _from2=_interopRequireDefault(_from);function _interopRequireDefault(obj){return obj&&obj.__esModule?obj:{default:obj};}var userReducer=function userReducer(){var state=arguments.length>0&&arguments[0]!==undefined?arguments[0]:{users:[]};var action=arguments[1];switch(action.type){case"GET_USERS":state={users:(0,_from2.default)(action.payload)};break;case"user.modalDelete":state=JSON.parse((0,_stringify2.default)(state));state.modal=state.modal?state.modal:{};state.modal.list_delete={show:true,id:action.id,phone:action.phone};break;case"user.modalDeleteHide":state=JSON.parse((0,_stringify2.default)(state));state.modal.list_delete={show:false,id:0,phone:''};break;case"user.delete":state=JSON.parse((0,_stringify2.default)(state));for(var index in state.users){if(state.users[index].id===action.id){state.users.splice(index,1);}}break;}return state;};module.exports={userReducer:userReducer};;var _temp=function(){if(typeof __REACT_HOT_LOADER__==='undefined'){return;}__REACT_HOT_LOADER__.register(userReducer,"userReducer","src/redux/reducers/userReducer.js");}();;