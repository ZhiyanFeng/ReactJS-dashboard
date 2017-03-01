const userReducer = (state = {
    users: [],
    storeEmployees: [],
    channel: []

}, action)=>{
    switch (action.type){
        case "SET_SEARCH_USERS":
            state = {
                users: Array.from(action.users)
            };
            break;
        case "SET_STORE_EMPLOYEES":
            state = {
                storeEmployees: action.storeEmployees
            };
            break;
        case "SET_CHANNEL_FOR_USER":
            state = {
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
                    state.users.splice(index, 1);
                }
            }
            break;

    }
    return state;

}

module.exports = {
    userReducer,
}
