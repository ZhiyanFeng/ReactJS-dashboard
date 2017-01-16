import greetings from './greetings';
import userReducer from "./userReducer";

module.exports = {
    //...greetings,
    ...userReducer,
};
//import {combineReducers} from "redux";
//import userReducer from "./userReducer";
//import activeUserReducer from "./activeUserReducer";
//
//
//const allReducers = combineReducers({
//        ...greetings,
//        users: userReducer,
//        activeUser: activeUserReducer
//    //form: formReducer
//
//})
//
//export default allReducers;
