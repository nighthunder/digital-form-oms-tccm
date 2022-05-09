import React from 'react';
import './styles.css';

import { connect } from 'react-redux';
import { TextField, Button, InputLabel, Select } from '@material-ui/core';
import Edit from '@mui/icons-material/Edit';
import QuestionMark from '@mui/icons-material/QuestionMark';
import VisibilityIcon from '@mui/icons-material/Visibility';
import PlusOne from '@mui/icons-material/Add';
// import { connect } from 'react-redux';

// const styles = {
//     Button: {
//       color: 'white'
//     }
// };

// function userLogout() {
//     return {
//       type: 'TOGGLE_LOGOUT',
//       isLogged: false,
//     }
//   }

function NewGroup(state) {
    
    // const history = useHistory();    

    console.log(state);

    // function logout() {
    //     dispatch(userLogout());
    //     window.location.href = '/';
    // }

    /*function clickHandler(){
        history.goBack();
    }*/

    return (
        <div className="groupQuestion">
            <div className="qst qst2 qst3">
                <div className="qstBodyGroup qstIconArea">
                    {/* <PlusOne className="Icon plusIcon" onClick={() => handleClickClone("group")}></PlusOne> */}
                    <PlusOne className="Icon plusIcon"></PlusOne>
                </div>
            </div>
            {/* <div className="groupHeader" id={question.qstId}> */}
            <div className="groupHeader" >
                {/* <TextField className="inputQst inputQst3" name={String(question.qstGroupId)} value={qstgroups[question.qstGroupId] ? qstgroups[question.qstGroupId] : question.dsc_qst_grp } onChange={handleChangeGroups}>{question.dsc_qst_grp}</TextField> */}
                <TextField className="inputQst inputQst3" name="teste" value="Novo Grupo">Novo Grupo</TextField>
                {/* <Edit className="Icon ediIcon" onClick={handleInfo}></Edit> */}
                <Edit className="Icon ediIcon"></Edit>
                <QuestionMark className="Icon qstIcon"></QuestionMark>
                {/* <QuestionMark className="Icon qstIcon" onClick={() => handleClickOpen(question, "group")}></QuestionMark> */}
                <VisibilityIcon className="Icon visIcon" ></VisibilityIcon>
                {/* <VisibilityIcon className="Icon visIcon"  onClick={() => handleToogle(question.dsc_qst_grp)}></VisibilityIcon> */}
                <p className="questionType groupType">Grupo de questões</p>
            </div>
        </div>
    );
}

export default NewGroup