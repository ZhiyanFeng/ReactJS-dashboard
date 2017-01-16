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
    console.log('active user reducer', state);
    return state;
}

export default activeUserReducer;
