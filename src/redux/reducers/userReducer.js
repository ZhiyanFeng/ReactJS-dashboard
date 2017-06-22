const userReducer = (state = {
    users: [],
    storeEmployees: [],
    channel: []
}, action)=>{
    switch (action.type){
        case "SET_SEARCH_USERS":
            state = {
                ...state,
                users: Array.from(action.users)
            };
            break;
        case "SET_STORE_EMPLOYEES":
            state = {
                ...state,
                storeEmployees: action.storeEmployees
            };
            break;
        case "SET_CHANNEL_FOR_USER":
            state = {
                ...state,
                channel: action.channel
            };
            break;
        case "user.modalDelete":
            state = JSON.parse(JSON.stringify(state)); 
            state.modal= state.modal ? state.modal : {};
            state.modal.list_delete = {
                show: true,
                id: action.id,
                phone: action.phone,
                for_location: action.for_location,
                location_id: action.location_id
            };
            break;
        case "user.modalDeleteHide":
            state = JSON.parse(JSON.stringify(state)); 
            state.modal.list_delete = {
                show: false,
                id: 0,
                phone: '',
            };
            break;
        case "user.delete":
            state = JSON.parse(JSON.stringify(state)); 
            for (const index in state.users){
                if(state.users[index].id === action.id){
                    state.users[index].is_valid = false;
                }
            }
            break;
        case "user.unsubscribeChannel":
            state = JSON.parse(JSON.stringify(state)); 
            for (const index in state.channel){
                if(state.channel[index].channel_id === action.channelId){
                    state.channel.splice(index,1);
                }
            }
            break;
    }
    return state;
}

module.exports = {
    userReducer,
}
