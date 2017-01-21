const activeUserReducer = (state = null 
, action)=>{
    switch (action.type){
        case "SELECT_USER":
            state = {
                ...state,
                activeUser: action.payload 
            };
            break;
    }
    return state;
}

module.exports = {
    activeUserReducer,
}
