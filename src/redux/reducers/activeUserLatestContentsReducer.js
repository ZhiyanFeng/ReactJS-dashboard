const activeUserLatestContentsReducer = (state = {
    activeUserLatestContents: {}

}, action)=>{
    switch (action.type){
        case "SET_ACTIVE_USER_LATEST_CONTENTS":
            state = {
                activeUserLatestContents: action.activeUserLatestContents
            };
            break;
    }
    return state;

}

module.exports = {
    activeUserLatestContentsReducer,
}
