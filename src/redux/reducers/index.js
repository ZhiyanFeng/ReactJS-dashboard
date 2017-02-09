import users from "./userReducer";
import authReducer from "./authReducer";
import locationReducer from "./locationReducer";
import activeUserReducer from "./activeUserReducer";

module.exports = {
    ...users,
    ...authReducer,
    ...locationReducer,
    ...activeUserReducer,
};
