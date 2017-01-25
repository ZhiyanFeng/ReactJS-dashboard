const apiUserReducer = (state = {
    users: []
}, action)=>{
    switch (action.type){
        case "GET_USERS":
            state = {
                ...state,
                users: [Array.from(action.payload)]
            };
            break;
    }
    return state;
}

module.exports = {
    apiUserReducer,
}
