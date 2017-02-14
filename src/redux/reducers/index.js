import users from "./userReducer";
import authReducer from "./authReducer";
import locationReducer from "./locationReducer";
import activeUserReducer from "./activeUserReducer";
import activeUserLatestContents from "./activeUserLatestContentsReducer"
import dashboardReducer from "./dashboardReducer";

module.exports = {
    ...users,
    ...authReducer,
    ...locationReducer,
    ...activeUserReducer,
    ...activeUserLatestContents,
    ...dashboardReducer,
};
