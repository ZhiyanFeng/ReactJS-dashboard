import users from "./userReducer";
import activeUser from "./activeUserReducer";

module.exports = {
    ...users,
    ...activeUser, 
};
