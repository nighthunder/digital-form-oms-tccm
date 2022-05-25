// View do formulário quando é preenchido.
import React, { useState, useEffect, useRef, cloneElement } from 'react';
import './styles.css';
import { useLocation } from "react-router-dom";
import { Scrollchor } from 'react-scrollchor';
import { TextField, Button, InputLabel, Select } from '@material-ui/core';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpwardRounded';
import ArrowDownwardIcon from '@mui/icons-material/ArrowDownwardRounded';
import Edit from '@mui/icons-material/Edit';
import QuestionMark from '@mui/icons-material/QuestionMark';
import VisibilityIcon from '@mui/icons-material/Visibility';
import PlusOne from '@mui/icons-material/Add';
import { makeStyles } from '@material-ui/styles';
import api from '../../services/api';
import { connect } from 'react-redux';
import { useHistory } from "react-router-dom";
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';
//import { Transition } from "react-transition-group";
//import { display } from '@mui/system';
// import NewGroup from '../../components/newGroup';
import ReactDOM from 'react-dom'
import ReactDOMServer from "react-dom/server";


const useStyles = makeStyles({
    root: {
      '& input': {
          fontSize: '0.75rem',
      }
    },
});

function EditUnpublishedForm({logged, user, participantId}) {

    const location = useLocation();  
    const classes = useStyles();
    console.log("Location Formulario", location);
    const titles = ['Admissão','Acompanhamento','Desfecho']
    const [form, setForm] = useState({}); // descrições das perguntas
    const [qstgroups, setQstGroups] = useState({}); // descrições dos grupos
    const [formError, setFormError] = useState('')
    const [formOk, setFormOk] = useState('')
    const history = useHistory();
    const [questions, setQuestions] = useState([]);
    const [contI, setContI] = useState(1);
    // const [groups, setGroups] = useState([]); // grupos
    // const [qstsorder, setQstOrder] = useState({}); // ordem das perguntas
    var qstsorder = [];
    var swapQstsOrder = [];
    const [loadedResponses, setLoadedResponses] = useState(false);
    const [hospitalName, setHospitalName] = useState('');

    // popup
    const [popupTitle, setPopupTitle] = useState('');
    const [questionTypeComment, setQuestionTypeComment] = useState('');
    const [questionComment, setQuestionComment] = useState('');
    const [questionListTypeComment, setQuestionListTypeComment] = useState('');
    const [questionGroupComment, setQuestionGroupComment] = useState('');
    const [popupBodyText, setPopupBodyText] = useState('');

    useEffect(() => {
        async function loadForm() {
            const response = await api.get('/form/' + location.state.modulo);
            setQuestions(response.data);
            // setQstOrder(response.data);

            //console.log("QUESTOES", questions);
            //console.log("formRecordId", location.state.formRecordId);
        }
        loadForm();
        setHospitalName(user[location.state.hospitalIndex].hospitalName);
    }, [])

    function handleChange(e) {
        const target = e.target;
        const value = target.value;
        const name = target.name;
        //console.log('idQuestão: ' + target.name, 'value: ' + target.value);
        setForm({
            ...form,
            [name]: value,
        });
        console.log("form", form);
    }
    
    function handleChangeGroups(e) {
        const target = e.target;
        const value = target.value;
        const name = target.name;
        console.log('idQuestão: ' + target.name, 'value: ' + target.value);
        setQstGroups({
            ...qstgroups,
            [name]: value,
        });
        console.log("questions groups", qstgroups);
    }

    function checkTitle(index, question) { // tratamento da repetição dos nomes dos grupos
        if(index-1 < 0) {
            return true;
        }
        if(typeof(questions[index - 1].dsc_qst_grp) == 'string') {
            if(question.dsc_qst_grp !== questions[index - 1].dsc_qst_grp) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    // popup
    const [open, setOpen] = React.useState(false);
    const handleClickOpen = (question, param) => {
        setOpen(false);
        setPopupTitle("Comentários");
        setPopupBodyText("");

        if(question.qst_group_comment && param === "group"){ 
            setQuestionGroupComment(question.qst_group_comment+".")
            setQuestionComment("");
            setQuestionTypeComment("");
            setQuestionListTypeComment("");
        }else{
            setQuestionGroupComment("")
        }

        if(question.qst_comment && param === "question"){ 
            setQuestionComment(question.qst_comment + ".")
        }else{
            setQuestionComment("")
        }

        if(question.qst_type && param === "question"){ 
            setQuestionTypeComment("Sobre o grupo "+ question.qst_type + " : " + question.qst_type_comment + ".")
        }else{
            setQuestionTypeComment("")
        }

        if(question.qst_list_type && param === "question"){ 
            setQuestionListTypeComment(question.qst_list_type + " : " + question.qst_list_type_comment + ".")
        }else{
            setQuestionListTypeComment("")
        }
        //setQuestionListTypeComment(`rere \n asdssss`);
        setOpen(true);
    };
    const handleInfo = (e) => {
        console.log("e", e);
        setOpen(false);
        setPopupTitle("[Atenção] Informações sobre a edição");
        setPopupBodyText("Neste modo de edição só é possível reodernar questões e agrupamentos ou alterar suas descrições. Para ser possível fazer mais alterações é necessário criar uma pesquisa derivada.");
        setQuestionComment("");
        setQuestionTypeComment("");
        setQuestionListTypeComment("");
        setQuestionGroupComment("");
        setOpen(true);
    };
    const handleReorder = () => {
        var orderQuestions = [];
        var listGroups = [];
        var listQuestions = [];
        var listGroupsQuestions = [];
        document.querySelectorAll('.uniQuestion').forEach(function(i) {
            orderQuestions.push(parseInt(i.getAttribute("id")))
        });
        document.querySelectorAll('.groupQuestion').forEach(function(i) {
            let dictValueCurrent = {}
            dictValueCurrent[parseInt(i.getAttribute("value"))] = i.querySelector('.MuiInputBase-input.MuiInput-input').value
            listGroups.push(dictValueCurrent)
        });
        qstsorder = [];
        orderQuestions.forEach((el, i) => {
            // console.log("i: ", i, "- el: ", el);
            let found = questions.find(element => element.qstId === el);
            // setQstOrder(qstsorder => [...qstsorder,found] );
            qstsorder.push(found)
            let dictValueCurrentListQuestions = {}
            let dictValueCurrentListGroupsQuestions = {}
            dictValueCurrentListQuestions[found.qstId] = found.dsc_qst
            dictValueCurrentListGroupsQuestions[found.qstGroupId] = found.qstId
            listQuestions.push(dictValueCurrentListQuestions)
            listGroupsQuestions.push(dictValueCurrentListGroupsQuestions)
        });
        console.log("listQuestions", listQuestions);
        console.log("listGroupsQuestions", listGroupsQuestions);
        console.log("listGroups", listGroups);
        console.log("qstsorder", qstsorder);
    };
    const handleAddSurvey = () => {
        history.push('/add-survey');
    };
    const handleAddBasedSurvey = () => {
        history.push('/add-based-survey');
    };
    const handleClose = () => {
        setOpen(false);
    };

    const handleToogle = (description) => {
        console.log("description", description);
        document.querySelectorAll('.uniQuestion').forEach(function(i) {
            if(i.getAttribute("value") === description){
                // console.log("i", i);
                if(i.style.display === "none"){
                    i.style.display = "inline";
                }else{
                    i.style.display = "none";
                }
            }
        });
    };

    const usernameRefs = useRef([]);

    usernameRefs.current = questions.map(
        (ref, index) =>   usernameRefs.current[index] = React.createRef()
    )
    
    const handleClickUpDown = (index, direction, question) => {        
        var elm = usernameRefs.current[index].current;
        var elm2
        if (direction == "UP"){
            if (elm.previousSibling) {
                elm2 = elm.previousSibling;
                if (elm.getAttribute("value") === elm2.getAttribute("value")) {
                    let orderelm = parseInt(elm.getAttribute("name"))
                    let keyelm = parseInt(elm.getAttribute("id"))
                    let orderelm2 = parseInt(elm2.getAttribute("name"))
                    let keyelm2 = parseInt(elm2.getAttribute("id"))
                    let tupla1 = {}
                    let tupla2 = {}
                    tupla1[keyelm] = orderelm2
                    tupla2[keyelm2] = orderelm
                    swapQstsOrder.push(tupla1, tupla2)
                    elm.setAttribute("name", orderelm2)
                    elm2.setAttribute("name", orderelm)
                    elm.parentNode.insertBefore(elm, elm2);
                }
            }
        }
        if (direction == "DOWN") {
            if(elm.nextSibling){
                elm2 = elm.nextSibling;
                if (elm.getAttribute("value") === elm2.getAttribute("value")) {
                    let orderelm = parseInt(elm.getAttribute("name"))
                    let keyelm = parseInt(elm.getAttribute("id"))
                    let orderelm2 = parseInt(elm2.getAttribute("name"))
                    let keyelm2 = parseInt(elm2.getAttribute("id"))
                    let tupla1 = {}
                    let tupla2 = {}
                    tupla1[keyelm] = orderelm2
                    tupla2[keyelm2] = orderelm
                    swapQstsOrder.push(tupla1, tupla2)
                    elm.setAttribute("name", orderelm2)
                    elm2.setAttribute("name", orderelm)
                    elm2.parentNode.insertBefore(elm2, elm);
                }
            }
        }
        console.log("swapQstsOrder", swapQstsOrder);
    };

    async function submit(e) {
        setFormError("");
        e.preventDefault();
        console.log(form);

        let request;
        let response;
        let param;

        console.log('ATUALIZAÇÃO DO FORM ', location.state.formRecordId);

        request = {
            questionsdescriptions: JSON.stringify(form),  
            modulo: location.state.modulo
        }

        //console.log( [ request.info['userid'], request.info['grouproleid'], request.info['hospitalunitid'], request.modulo, request.questionsdescriptions ]);

        response = await api.put('/formqstdesc/' + location.state.modulo, request);

        let errors;

        if (response){
            setFormError(response.data[0].msgRetorno);
        }

        request = {
            qstgroups: JSON.stringify(qstgroups),  
            modulo: location.state.modulo
        }

        response = await api.put('/formgroupsdesc/' + location.state.modulo, request);

        if (response){
            setFormError(response.data[0].msgRetorno);
        }

        request = {
            questionsorder: JSON.stringify(swapQstsOrder),  
            modulo: location.state.modulo
        }

        // console.log("JSON.stringify(swapQstsOrder)", JSON.stringify(swapQstsOrder));

        response = await api.put('/formqstorder/' + location.state.modulo, request);

        if (response){
            setFormError(response.data[0].msgRetorno);
        }

        /*request = {
            qstsorder: JSON.stringify(qstsorder),  
            modulo: location.state.modulo
        }

        response = await api.put('/formqstorder/' + location.state.modulo, request);*/

    }

    function handleBackButton(){
        history.goBack();
    }

    function FormError(props){
        return <p className="error error2">{props.formError}</p>
    }

    function FormOk(props){
        return <p className="error error2">{props.formOk}</p>
    }

    // const [newGroup, setNewGroup] = useState();

    // function NewGroup() {
        
    //     return (
    //         <div className="groupQuestion">
    //             <div className="qst qst2 qst3">
    //                 <div className="qstBodyGroup qstIconArea">
    //                     <PlusOne className="Icon plusIcon" onClick={() => handleClickNewGroup("group")}></PlusOne>
    //                     {/* <PlusOne className="Icon plusIcon"></PlusOne> */}
    //                 </div>
    //             </div>
    //             {/* <div className="groupHeader" id={question.qstId}> */}
    //             <div className="groupHeader" >
    //                 {/* <TextField className="inputQst inputQst3" name={String(question.qstGroupId)} value={qstgroups[question.qstGroupId] ? qstgroups[question.qstGroupId] : question.dsc_qst_grp } onChange={handleChangeGroups}>{question.dsc_qst_grp}</TextField> */}
    //                 <TextField className="inputQst inputQst3" name="teste" placeholder="Novo Grupo" value="">Novo Grupo</TextField>
    //                 {/* <Edit className="Icon ediIcon" onClick={handleInfo}></Edit> */}
    //                 <Edit className="Icon ediIcon"></Edit>
    //                 <QuestionMark className="Icon qstIcon"></QuestionMark>
    //                 {/* <QuestionMark className="Icon qstIcon" onClick={() => handleClickOpen(question, "group")}></QuestionMark> */}
    //                 <VisibilityIcon className="Icon visIcon" ></VisibilityIcon>
    //                 {/* <VisibilityIcon className="Icon visIcon"  onClick={() => handleToogle(question.dsc_qst_grp)}></VisibilityIcon> */}
    //                 <p className="questionType groupType">Grupo de questões</p>
    //             </div>
    //             <div className="qst qst2">
    //                 <div className="qstBody qstIconArea">
    //                     <PlusOne className="Icon plusIcon" onClick={handleInfo}></PlusOne>
    //                 </div>
    //             </div>
    //         </div>
    //     );
        
    // }
    const handleClickNewQuestion = (id) => {

        let myObj = questions.find(obj => obj.qstId === id);
        let myObjIndex = questions.findIndex(obj => obj.qstId === id);
        console.log("myObjIndex", myObjIndex);

        let left = questions.slice(0, myObjIndex)
        let right = questions.slice(myObjIndex)

        console.log("questions", questions);
        console.log("right", right);

        let objCopy = {...myObj};

        setContI(contI + 1);

        objCopy.dsc_qst = "Nova Questão - " + contI
        objCopy.qstId = parseInt(1000 + (Math.random() * (20000-1000)));
        objCopy.qstOrder = parseInt(100000 + (Math.random() * (200000-100000)));
        objCopy.qst_type = "Number question"
        objCopy.rsp_pad = null
        objCopy.rsp_padId = null

        left.push(objCopy);
        console.log("left", left);
        let mergeArrays = [...left, ...right]
        console.log("mergeArrays", mergeArrays);

        setQuestions(mergeArrays)

    }
    const handleClickNewGroup = (id) => {
        
        // const target = e.target;
        // const value = target.value;
        // const name = target.name;
        // //console.log('idQuestão: ' + target.name, 'value: ' + target.value);
        // setQstGroups({
        //     ...qstgroups,
        //     [name]: value,
        // });
        // console.log("questions groups", qstgroups);

        let myObj = questions.find(obj => obj.qstId === id);
        let myObjIndex = questions.findIndex(obj => obj.qstId === id);
        console.log("myObjIndex", myObjIndex);

        let left = questions.slice(0, myObjIndex)
        let right = questions.slice(myObjIndex)

        console.log("questions", questions);
        console.log("right", right);

        let objCopy = {...myObj};

        setContI(contI + 1);

        objCopy.dsc_qst = "Nova Questão"
        objCopy.dsc_qst_grp = "Novo Grupo - " + contI
        objCopy.qstGroupId = String(parseInt(1000 + (Math.random() * (20000-1000))))
        objCopy.qstId = parseInt(1000 + (Math.random() * (20000-1000)));
        objCopy.qstOrder = parseInt(100000 + (Math.random() * (200000-100000)));
        objCopy.qst_type = "Number question"
        objCopy.rsp_pad = null
        objCopy.rsp_padId = null

        left.push(objCopy);
        console.log("left", left);
        let mergeArrays = [...left, ...right]
        console.log("mergeArrays", mergeArrays);

        setQuestions(mergeArrays)

        // setQuestions(prevState => {
        //     let left = prevState.components.slice(0, myObjIndex)
        //     let right = prevState.components.slice(myObjIndex)
        //     console.log("left", left);
        //     console.log("right", right);
        //     return {
        //         components: left.concat(elements, right)
        //     }
        // });

        // setQuestions([
        //     ...questions.slice(0, 1),
        //     objCopy,
        //     ...questions.slice(1)
        // ])

        // console.log("myObj", myObj);

        // let novoGrupo = ReactDOMServer.renderToStaticMarkup(<NewGroup />);
        // // let node = ReactDOM.render(novoGrupo);
        // // console.log("node", node);
        // console.log("novoGrupo", novoGrupo);

        // // setNewGroup(<NewGroup />);
        // // console.log("newGroup", newGroup);

        // console.log("click clone", id);
        // // if(tipo == "group"){
        //     // let elem = document.getElementsByClassName("groupQuestion");
        //     let elem;

        //     document.querySelectorAll('.groupQuestion').forEach(function(i) {
        //         if(parseInt(i.getAttribute("id")) == id){
        //             elem = i
        //         }
        //     });

            
            
        //     let clone = elem.cloneNode(true);
        //     console.log("clone", clone);
        //     // document.querySelector(".module").insertBefore(clone, elem);
        //     elem.insertAdjacentHTML('beforebegin', novoGrupo);

        //     // clone.setAttribute('value', 'Novo Grupo');
        //     // document.querySelector(".module").appendChild(clone);
        //     // document.getElementsByClassName("module").appendChild(clone);
        //     // console.log("elem", document.querySelector(".module"));
        // // }
        // // ev.preventDefault();
        // // const { emails, input } = this.state;
        // //     if (!emails.includes(input))
        // //         this.setState({ emails: [...emails, input]});
    }

    return (
        <main className="container">
            <div>
                <header>
                    <h1 className="questionnaireDesc"> <b>Pesquisa:</b> {location.state.questionnaireDesc} ( {location.state.questionnaireVers} ) {location.state.questionnaireStatus}  </h1>
                </header>
                <hr/>
                <div className="mainNav">
				    <h2 className="pageTitle pageTitle1">Módulo { location.state.modulo } - { titles[location.state.modulo-1] } - {location.state.moduleStatus} [Edição]</h2>
                    <ArrowBackIcon className="ArrowBack ArrowBack1" onClick={handleBackButton}/>
                    <Scrollchor to="#vodan_br"><ArrowUpwardIcon className="ArrowUp" /></Scrollchor>
                </div>
               
                <form className="module" onSubmit={submit}>
                    <>
                    { questions.length === 0 && (location.state.formRecordId ? !loadedResponses : true) &&
                        <div className="loading">
                            <img src="assets/loading.svg" alt="Carregando"/>
                        </div>
                    }
                    {
                        console.log("QUESTIONS2", questions)
                    }
                    {questions.map((question, index) => (
                        <>
                            {/* Se for um novo grupo de questões*/}
                            { (question.dsc_qst_grp !== ""  && checkTitle(index, question)) &&
                                <div className="groupQuestion" id={question.qstId} value={question.qstGroupId}>
                                    <div className="qst qst2 qst3">
                                        <div className="qstBodyGroup qstIconArea">
                                            <PlusOne className="Icon plusIcon" onClick={() => handleClickNewGroup(question.qstId)}></PlusOne>
                                        </div>
                                    </div>
                                    <div className="groupHeader" id={question.qstId}>
                                        <TextField className="inputQst inputQst3" name={String(question.qstGroupId)} value={qstgroups[question.qstGroupId] ? qstgroups[question.qstGroupId] : question.dsc_qst_grp } onChange={handleChangeGroups}>{question.dsc_qst_grp}</TextField>
                                        <Edit className="Icon ediIcon" onClick={handleInfo}></Edit>
                                        <QuestionMark className="Icon qstIcon" onClick={() => handleClickOpen(question, "group")}></QuestionMark>
                                        <VisibilityIcon className="Icon visIcon"  onClick={() => handleToogle(question.dsc_qst_grp)}></VisibilityIcon>
                                        <p className="questionType groupType">Grupo de questões</p>
                                    </div>
                                </div>
                            }
                            <div ref={usernameRefs.current[index]} id={question.qstId} value={question.dsc_qst_grp} className="uniQuestion" name={question.qstOrder}>
                                <div className="qst qst2" key={question.qstId} >
                                    <div className="qst qst2">
                                        <div className="qstBody qstIconArea">
                                            <PlusOne className="Icon plusIcon" onClick={() => handleClickNewQuestion(question.qstId)}></PlusOne>
                                        </div>
                                    </div>
                                    <div className="qstBody">
                                    
                                    {/* Se for do tipo Date question*/}
                                    { (question.qst_type === "Date question") && 
                                    <div>
                                        <InputLabel className="qstLabel">Questão</InputLabel>
                                        <Edit className="Icon ediIcon" onClick={handleInfo}></Edit>
                                        <QuestionMark className="Icon qstIcon" onClick={() => handleClickOpen(question, "question")}></QuestionMark>
                                        <ArrowUpwardIcon className="ArrowUp2 Icon" onClick={() => handleClickUpDown(index, "UP", question)} />
                                        <ArrowDownwardIcon className="ArrowUp1 Icon" onClick={() => handleClickUpDown(index, "DOWN", question)} />
                                        <TextField className={classes.root} className="inputQst inputQst2" name={String(question.qstId)} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } fullWidth multiline>{question.dsc_qst}</TextField>
                                        <p className="questionType">Tipo da questão: {question.qst_type}</p>
                                        {
                                            question.qst_list_type ?  <p className="questionType">Tipo da lista: {question.qst_list_type}</p> : ''
                                        }
                                        { question.sub_qst !== '' &&
                                        <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                                        }
                                    </div>
                                    }

                                    {/* Se for do tipo Number question*/}
                                    { (question.qst_type === "Number question") && 
                                    <div>
                                    {/*<TextField  type="number" name={String(question.qstId)} label={question.dsc_qst} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } />*/}
                                    <InputLabel className="qstLabel">Questão:</InputLabel>
                                    <Edit className="Icon ediIcon" onClick={handleInfo}></Edit>
                                    <QuestionMark className="Icon qstIcon" onClick={ ( ) => handleClickOpen(question, "question") }></QuestionMark>
                                    <ArrowUpwardIcon className="ArrowUp2 Icon" onClick={() => handleClickUpDown(index, "UP", question)} />
                                    <ArrowDownwardIcon className="ArrowUp1 Icon" onClick={() => handleClickUpDown(index, "DOWN", question)} />
                                    <TextField className="inputQst inputQst2"  name={String(question.qstId)} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } onChange={handleChange} fullWidth multiline>{question.dsc_qst}</TextField>
                                    <p className="questionType">Tipo da questão: {question.qst_type}</p>
                                    {
                                        question.qst_list_type ?  <p className="questionType">Tipo da lista: {question.qst_list_type}</p> : ''
                                    }
                                    { question.sub_qst !== '' &&
                                    <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                                    }
                                    </div>
                                    }

                                    {/* Se for do tipo List question ou YNU_Question ou YNUN_Question e tenha menos de 6 opções */}
                                    { (question.qst_type === "List question" || question.qst_type === "YNU_Question" || question.qst_type === "YNUN_Question") && ( (question.rsp_pad.split(',')).length < 6 ) &&
                                    <div className="MuiTextField-root  MuiTextField-root2 MuiForm">
                                        <InputLabel className="qstLabel">Questão:</InputLabel>
                                        <Edit className="Icon ediIcon" onClick={handleInfo}></Edit>
                                        <QuestionMark className="Icon qstIcon" onClick={ ( ) => handleClickOpen(question, "question") }></QuestionMark>
                                        <ArrowUpwardIcon className="ArrowUp2 Icon" onClick={() => handleClickUpDown(index, "UP", question)} />
                                        <ArrowDownwardIcon className="ArrowUp1 Icon" onClick={() => handleClickUpDown(index, "DOWN", question)} />
                                        <TextField  className="inputQst inputQst2" onChange={handleChange} name={String(question.qstId)} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst }  fullWidth multiline>{question.dsc_qst}</TextField>
                                        <p className="questionType">Tipo da questão: {question.qst_type}</p>
                                        {
                                            question.qst_list_type ?  <p className="questionType">Tipo da lista: {question.qst_list_type}</p> : ''
                                        }
                                        <p className="subQstDesc">Respostas padronizadas</p>
                                        <Select multiple native label={question.dsc_qst} aria-label={question.dsc_qst} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : '' }>
                                                {question.rsp_pad.split(',').map((item) => (
                                                    <option key={item} value={item}>{ item }</option>
                                                ))}
                                        </Select>
                                        { question.sub_qst !== '' &&
                                        <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                                        }
                                    </div>
                                    } 

                                    {/* Se for do tipo List question ou YNU_Question ou YNUN_Question e tenha 6 ou mais opções */}
                                    { (question.qst_type === "List question" || question.qst_type === "YNU_Question" || question.qst_type === "YNUN_Question") && ( (question.rsp_pad.split(',')).length >= 6 ) &&
                                    <div className="MuiTextField-root  MuiTextField-root2 MuiForm">
                                        <InputLabel className="qstLabel">Questão:</InputLabel>
                                        <Edit className="Icon ediIcon" onClick={handleInfo}></Edit>
                                        <QuestionMark className="Icon qstIcon" onClick={ ( ) => handleClickOpen(question, "question") }></QuestionMark>
                                        <ArrowUpwardIcon className="ArrowUp2 Icon" onClick={() => handleClickUpDown(index, "UP", question)} />
                                        <ArrowDownwardIcon className="ArrowUp1 Icon" onClick={() => handleClickUpDown(index, "DOWN", question)} />
                                        <TextField  className="inputQst inputQst2" onChange={handleChange} name={String(question.qstId)} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst }  fullWidth multiline>{question.dsc_qst}</TextField>
                                        <p className="questionType">Tipo da questão: {question.qst_type}</p>
                                        {
                                            question.qst_list_type ?  <p className="questionType">Tipo da lista: {question.qst_list_type}</p> : ''
                                        }
                                        <p className="subQstDesc">Respostas padronizadas</p>
                                        <Select multiple native label={question.dsc_qst} label={question.dsc_qst} aria-label={question.dsc_qst} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : '' }>
                                                {question.rsp_pad.split(',').map((item) => (
                                                    <option key={item} value={item}>{ item }</option>
                                                ))}
                                        </Select>
                                        { question.sub_qst !== '' &&
                                        <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                                        }
                                    </div>
                                    } 

                                    {/* Se for do tipo Text_Question ou Laboratory question ou Ventilation question*/}
                                    { (question.qst_type === "Text_Question" || question.qst_type === "Laboratory question" || question.qst_type === "Ventilation question") && 
                                    <div>
                                    <InputLabel className="qstLabel">Questão:</InputLabel>
                                    <Edit className="Icon ediIcon" onClick={handleInfo}></Edit>
                                    <QuestionMark className="Icon qstIcon" onClick={ ( ) => handleClickOpen(question, "question") }></QuestionMark>
                                    <ArrowUpwardIcon className="ArrowUp2 Icon" onClick={() => handleClickUpDown(index, "UP", question)} />
                                    <ArrowDownwardIcon className="ArrowUp1 Icon" onClick={() => handleClickUpDown(index, "DOWN", question)} />
                                    <TextField  className="inputQst inputQst2" name={String(question.qstId)} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } fullWidth multiline>{question.dsc_qst}</TextField>
                                    <p className="questionType">Tipo da questão: {question.qst_type}</p>
                                    {
                                        question.qst_list_type ?  <p className="questionType">Tipo da lista: {question.qst_list_type}</p> : ''
                                    }
                                    { question.sub_qst !== '' &&
                                    <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                                    }
                                    </div>
                                    }

                                    {/* Se for do tipo Boolean_Question*/}
                                    { (question.qst_type === "Boolean_Question") && 
                                    <div className="MuiTextField-root  MuiTextField-root2 MuiForm">
                                        <InputLabel className="qstLabel">Questão:</InputLabel>
                                        <Edit className="Icon ediIcon" onClick={handleInfo}></Edit>
                                        <QuestionMark className="Icon qstIcon" onClick={ ( ) => handleClickOpen(question, "question") }></QuestionMark>
                                        <ArrowUpwardIcon className="ArrowUp2 Icon" onClick={() => handleClickUpDown(index, "UP", question)} />
                                        <ArrowDownwardIcon className="ArrowUp1 Icon" onClick={() => handleClickUpDown(index, "DOWN", question)} />
                                        <TextField  className="inputQst inputQst2" name={String(question.qstId)} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } fullWidth multiline>{question.dsc_qst}</TextField>
                                        <p className="questionType">Tipo da questão: {question.qst_type}</p>
                                        {
                                            question.qst_list_type ?  <p className="questionType">Tipo da lista: {question.qst_list_type}</p> : ''
                                        }
                                        <p className="subQstDesc">Respostas padronizadas</p>
                                        <Select multiple native label={question.dsc_qst} aria-label={question.dsc_qst} onChange={handleChange}>
                                            <option label='Sim'/>
                                            <option label='Não'/>
                                        </Select>
                                        { question.sub_qst !== '' &&
                                        <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                                        }
                                    </div>
                                    } 
                                    </div>    
                                </div>
                            </div>
                        </>
                    ))}
                    </>
                    <div className="form-submit">
                        { formError?   <FormError formError={formError}></FormError> : ''  } 
                        { formOk?   <FormOk formOk={formOk}></FormOk> : ''  } 
                        {/* <Button variant="contained" type="submit" color="primary">Salvar</Button> */}
                        {/* <Button onClick={handleReorder} type="submit" variant="contained" color="primary">Salvar</Button> */}
                        <Button onClick={handleReorder} variant="contained" color="primary">Salvar</Button>
                    </div>
                </form>
                <Dialog key={Math.random()}
                            open={open}
                            onClose={handleClose}
                            aria-labelledby="alert-dialog-title"
                            aria-describedby="alert-dialog-description"
                            >
                            <DialogTitle id="alert-dialog-title">
                                {popupTitle}
                            </DialogTitle>
                            <DialogContent>
                                <DialogContentText id="alert-dialog-description">
                                {popupBodyText}
                                <b>{questionComment}</b><br/>
                                <b>{questionGroupComment}</b><br/>
                                {
                                   questionTypeComment? <p><b>Tipo da questão: </b><i>{questionTypeComment}</i><br/></p> : ''
                                }
                                {
                                   questionListTypeComment ? <p><b>Tipo da lista:</b><i>{questionListTypeComment}</i><br/></p> : ''
                                }
                                </DialogContentText>
                            </DialogContent>
                            <DialogActions>
                                <Button onClick={handleClose}>Fechar [x]</Button>
                            </DialogActions>
                </Dialog>
                <aside> 
                    <p className="sidebarTitle">Menu de navegação</p>
                    {questions.map((question, index) => (
                        (question.dsc_qst_grp !== ""  && checkTitle(index, question)) && 
                            <Scrollchor className="scrollchorlink" to={'#' + question.qstId} >
                                <div className="anchorLink" arial-label={question.dsc_qst_grp}>{question.dsc_qst_grp}</div>
                            </Scrollchor>
                    ))}    
                </aside>
                
            </div>
        </main>
    );
}
export default connect(state => ({ logged: state.logged, user:state.user, participantId: state.participantId }))(EditUnpublishedForm);