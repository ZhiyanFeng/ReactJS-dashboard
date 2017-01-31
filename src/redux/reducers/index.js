import users from "./userReducer";
import authReducer from "./authReducer";

module.exports = {
    ...users,
    ...authReducer,
};
