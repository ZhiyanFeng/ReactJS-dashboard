import users from "./userReducer";
import authReducer from "./authReducer";
import locationReducer from "./locationReducer";

module.exports = {
    ...users,
    ...authReducer,
    ...locationReducer,
};
