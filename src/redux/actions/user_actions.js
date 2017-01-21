export const SelectUser = (user)=>{
    console.log("you select user", user);
    return {
        type: "SELECT_USER",
        payload: user
    }
};
