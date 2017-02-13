import users from "./userReducer";
import authReducer from "./authReducer";
import locationReducer from "./locationReducer";
import activeUserReducer from "./activeUserReducer";
import dashboardReducer from "./dashboardReducer";

module.exports = {
    ...users,
    ...authReducer,
    ...locationReducer,
    ...activeUserReducer,
    ...dashboardReducer,
};
