const activeUserReducer = (state = {
    activeUser: {}

}, action)=>{
    switch (action.type){
        case "SET_ACTIVE_USER":
            state = {
                activeUser: action.activeUser
            };
            break;
    }
    return state;

}

module.exports = {
    activeUserReducer,
}
