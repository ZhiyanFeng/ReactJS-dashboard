import users from "./userReducer";
import authReducer from "./authReducer";
import locationReducer from "./locationReducer";
import channelReducer from "./channelReducer";
import locationDetailReducer from "./locationDetailReducer";
import activeUserReducer from "./activeUserReducer";
import activeUserLatestContents from "./activeUserLatestContentsReducer"
import dashboardReducer from "./dashboardReducer";
import storePhotoReducer from "./storePhotoReducer";

module.exports = {
    ...users,
    ...authReducer,
    ...locationReducer,
    ...locationDetailReducer,
    ...activeUserReducer,
    ...activeUserLatestContents,
    ...dashboardReducer,
    ...storePhotoReducer,
    ...channelReducer
};
