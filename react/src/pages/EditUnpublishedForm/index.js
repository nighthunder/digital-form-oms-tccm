// View do formulário quando é preenchido.
import React, { useState, useEffect, useRef, cloneElement } from 'react';
import './styles.css';
import { useLocation } from "react-router-dom";
import { Scrollchor } from 'react-scrollchor';
import { TextField, Button, InputLabel, Select, Checkbox } from '@material-ui/core';
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
import NewInput from '../../components/NewInput';
import ModelSelectType from '../../components/ModelSelectType';
import ReactDOM from 'react-dom'
import ReactDOMServer from "react-dom/server";
import { SingleSelect } from "react-select-material-ui";
import FormControlLabel from '@mui/material/FormControlLabel';
import { Container } from '../../components/ContainerNewQuestions';


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
    const [contI, setContI] = useState(0);
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
    
    const [idQuestion, setIdQuestion] = useState()
    const [openNewQuestion, setOpenNewQuestion] = React.useState(false);

    const [newListType, setNewListType] = useState([]) // novos tipos de lista - Formato: [id_listtype: descricao]
    const [questionListType, setQuestionListType] = useState([]) // questões/tipo de lista - Formato: [id_questao: id_listtype]
    const [answerListType, setAnswerListType] = useState([]) // respostas dos tipos de lista - [id_listofvalues: descricao]
    const [answerListType2, setAnswerListType2] = useState([]) // respostas dos tipos de lista - Formato: [id_listofvalues: id_listtype]
    // const [countLastListOfValuesId, setCountLastListOfValuesId] = useState(0)
    // const [listSubordinate, setListSubordinate] = useState([]) // Formato: [id_questaosubordinada: id_questaosubordinante]
    // const [listValueSubordinate, setListValueSubordinate] = useState([]) // Formato: [id_daquestao: id_dovalor1, id_dovalor2, id_dovalor3]
    const [error, setError] = useState([]);
    const [success, setSuccess] = useState([]);

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

    //Options para os selects do form de novas questões
    const optionsSubordinateQuestion = []
    questions.map(
        (ref, index) => optionsSubordinateQuestion.push({ label: ref.dsc_qst, value: ref.qstId })
    )
    const dictOption = [];
    const options = [];
    questions.forEach(element => {
        if(!dictOption.includes(element.qst_type)){
            if(element.qst_type != "List question"){
                // console.log('element.qst_type', element.qst_type);
                options.push({ label: element.qst_type_comment + " - " + element.qst_type, value: element.qst_type })
                dictOption.push(element.qst_type)
            }
        }        
    });

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

    // const [creationDate, setCreationDate] = useState('');
    function convertToDate(somedate){
        return String(somedate.getFullYear()+
              "-"+(somedate.getMonth()+1)+
              "-"+somedate.getDate()+
              " "+somedate.getHours()+
              ":"+somedate.getMinutes()+
              ":"+somedate.getSeconds());
    }

    // const [success, setSuccess] = useState([]);
    // const messageSucesso = [];
    // const messageErro = [];
    
    // async function handleReorder() {

    // };

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

    const [buttonOpen, setButtonOpen] = useState(true); 

    async function updateQstType(listQuestionsTypes){
        let param;
        let response;
        param = {
            stringtypes: JSON.stringify(listQuestionsTypes)
        }

        response = await api.put('/formqsttype/', param).catch( function (error) {
            console.log(error)
            if(error.response.data.Message) {
                // setError(error => [...error,error.response.data.Message]);
                setFormError(response.data[0].msgRetorno);
            } else {
                // setError(error => [...error,error.response.data.Message]);
                setFormError(response.data[0].msgRetorno);
            }
        });
        if(response) {
            // setSuccess(success => [...success,response.data.Message]);
            setFormOk(response.data[0].msgRetorno)
        }
    }

    async function submit(e) {
        setFormError("");
        e.preventDefault();
        // console.log(form);

        // let request;
        // let response;
        // let param;

        // console.log('ATUALIZAÇÃO DO FORM ', location.state.formRecordId);

        // request = {
        //     questionsdescriptions: JSON.stringify(form),  
        //     modulo: location.state.modulo
        // }

        // //console.log( [ request.info['userid'], request.info['grouproleid'], request.info['hospitalunitid'], request.modulo, request.questionsdescriptions ]);

        // response = await api.put('/formqstdesc/' + location.state.modulo, request);

        // let errors;

        // if (response){
        //     setFormError(response.data[0].msgRetorno);
        // }

        // request = {
        //     qstgroups: JSON.stringify(qstgroups),  
        //     modulo: location.state.modulo
        // }

        // response = await api.put('/formgroupsdesc/' + location.state.modulo, request);

        // if (response){
        //     setFormError(response.data[0].msgRetorno);
        // }

        // request = {
        //     questionsorder: JSON.stringify(swapQstsOrder),  
        //     modulo: location.state.modulo
        // }

        // // console.log("JSON.stringify(swapQstsOrder)", JSON.stringify(swapQstsOrder));

        // response = await api.put('/formqstorder/' + location.state.modulo, request);

        // if (response){
        //     setFormError(response.data[0].msgRetorno);
        // }

        // /*request = {
        //     qstsorder: JSON.stringify(qstsorder),  
        //     modulo: location.state.modulo
        // }

        // response = await api.put('/formqstorder/' + location.state.modulo, request);*/

        if (location.state.motherID !== location.state.questionnaireID){
            let param;
            let response;
            console.log("submit - salvamento");
            var listNewOrderQuestions = []
            var orderQuestions = [];
            var listGroups = [];
            var listQuestions = [];
            var listGroupsQuestions = [];
            var listQuestionsTypes = [];
            var listSubordinate = [];
            var listValueSubordinate = [];
            

            var pairKeyGroupId = {}

            let lastGroupId = await api.get('/formgroupid/');
            lastGroupId = parseInt(lastGroupId.data[0].msgRetorno);

            let lastQuestionId = await api.get('/formqstid/');
            lastQuestionId = parseInt(lastQuestionId.data[0].msgRetorno);

            let description = "Formulário de " + titles[location.state.modulo-1]

            // setCreationDate(convertToDate(new Date()));
            let dateCreate = convertToDate(new Date())
           
            // console.log("lastQuestionId", lastQuestionId);
            document.querySelectorAll('.uniQuestion').forEach(function(i) {
                orderQuestions.push(parseInt(i.getAttribute("id")))
            });
            document.querySelectorAll('.groupQuestion').forEach(function(el, i) {
                console.log("el, i", el, i);
                pairKeyGroupId[parseInt(el.getAttribute("value"))] = lastGroupId + i
                let dictValueCurrent = {}
                dictValueCurrent[lastGroupId + i] = el.querySelector('.MuiInputBase-input.MuiInput-input').value
                listGroups.push(dictValueCurrent)
            });
            console.log("pairKeyGroupId", pairKeyGroupId);
            qstsorder = [];
            // console.log("orderQuestions", orderQuestions);
            orderQuestions.forEach((el, i) => {
                // console.log("i: ", i, "- el: ", el);
                let found = questions.find(element => element.qstId === el);
                // setQstOrder(qstsorder => [...qstsorder,found] );
                qstsorder.push(found)
                // console.log("found", found);

                let dictValueCurrentListQuestions = {}
                let dictValueCurrentListGroupsQuestions = {}
                let dictValueCurrentlistQuestionsTypes = {}
                let dictValueCurrentlistNewOrderQuestions = {}

                dictValueCurrentlistQuestionsTypes[lastQuestionId + i] = found.qst_type_id

                dictValueCurrentListQuestions[lastQuestionId + i] = found.dsc_qst
                dictValueCurrentlistNewOrderQuestions[lastQuestionId + i] = found.qstOrder
                if (parseInt(found.qstGroupId)){
                    dictValueCurrentListGroupsQuestions[lastQuestionId + i] = pairKeyGroupId[parseInt(found.qstGroupId)]
                }else{
                    dictValueCurrentListGroupsQuestions[lastQuestionId + i] = null
                }

                listQuestions.push(dictValueCurrentListQuestions)
                listGroupsQuestions.push(dictValueCurrentListGroupsQuestions)
                listQuestionsTypes.push(dictValueCurrentlistQuestionsTypes)
                listNewOrderQuestions.push(dictValueCurrentlistNewOrderQuestions)
            });
            // console.log(location.state.motherID, " - ", location.state.questionnaireID);
            
            // let request;
            // let response;
            
            // request = {
            //     stringgroups: JSON.stringify(listGroups),
            //     info: user[location.state.hospitalIndex]
            // }

            // response = await api.put('/formgroup/', request);

            // if (response){
            //     // setFormError(response.data[0].msgRetorno);
            //     console.log("deu certo!");
            // }

            qstsorder.forEach((element,index )=> {
                
                if(element.sub_qst.length > 0){
                    // console.log("element", element);
                    var found_subordinante;
                    var found_subordinada;
                    listQuestions.forEach((el,index_2) => {
                        let obj = Object.values(el);
                        if (obj == element.sub_qst){
                            // console.log("obj", obj[0]);
                            // var found_obj = listQuestions.find(el => el === obj[0]);
                            found_subordinante = Object.keys(el);
                            // console.log("found_obj", found_obj);
                            // console.log("found_subordinante", found_subordinante);
                        }
                        if(obj == element.dsc_qst){
                            found_subordinada = Object.keys(el);
                            // console.log("found_subordinada", found_subordinada);
                        }
                    })

                    try {
                        let sub_q = {};
                        // console.log("found_subordinada", found_subordinada);
                        sub_q[found_subordinada[0]] = found_subordinante[0];
                        listSubordinate.push(sub_q)

                        let str_sub = '' + element.sub_qst_values;
                        let str_array_replace_sub = str_sub.replaceAll(",", ';');
                        let sub_q_2 = {};
                        // console.log("found_subordinada", found_subordinada);
                        sub_q_2[found_subordinada[0]] = str_array_replace_sub;
                        listValueSubordinate.push(sub_q_2)
                        
                    } catch (error) {
                        console.log("error", error);
                    }
    
                }
                
            });

            // // Salvamento do modulo N1 ==========================================
            // param = {
            //     userid : user[0].userid,    
            //     grouproleid : user[0].grouproleid,    
            //     hospitalunitid : user[0].hospitalunitid, 
            //     description: description,
            //     moduleStatusID: 2,
            //     questionnaireID: location.state.questionnaireID,
            //     lastModification: dateCreate,
            //     creationDate: dateCreate,
            // }

            // response = await api.post('/module/', param).catch( function (error) {
            //     console.log(error)
            //     if(error.response.data.Message) {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     } else {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     }
            // });
            // if(response) {
            //     // setSuccess(success => [...success,response.data.Message]);
            //     // setFormOk(response.data[0].msgRetorno)
            //     console.log("N1 OK - ", response.data);
            // }
            // // =======================================================================

            // // Salvamento da ordem das perguntas N2 =====================================
            // let lastModuloId = await api.get('/formmoduleid/');
            // lastModuloId = parseInt(lastModuloId.data[0].msgRetorno);

            // param = {
            //     questionsorder: JSON.stringify(listNewOrderQuestions),
            //     modulo: lastModuloId
            // }

            // response = await api.post('/formpostqstorder/' + lastModuloId, param).catch( function (error) {
            //     console.log("N2 - ", error)
            //     console.log("N2 - ", response.data);
            //     if(error.response.data.Message) {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     } else {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     }
            // });
            // if(response) {
            //     // setSuccess(success => [...success,response.data.Message]);
            //     setFormOk(response.data[0].msgRetorno)
            //     // console.log("N2 OK - ", response.data[0].msgRetorno);

            // }

            // // =======================================================================

            // Salvamento das perguntas N3 ==============================================
            param = {
                stringquestions: JSON.stringify(listQuestions)
            }

            response = await api.put('/formqst/', param).catch( function (error) {
                console.log(error)
                console.log("N3 - ", response.data);
                if(error.response.data.Message) {
                    // setError(error => [...error,error.response.data.Message]);
                    setFormError(response.data[0].msgRetorno);
                } else {
                    // setError(error => [...error,error.response.data.Message]);
                    setFormError(response.data[0].msgRetorno);
                }
            });
            if(response) {
                // setSuccess(success => [...success,response.data.Message]);
                setFormOk(response.data[0].msgRetorno)
                updateQstType(listQuestionsTypes); 
            }

            param = {
                language: 1,
                stringquestions: JSON.stringify(listQuestions)
            }

            response = await api.put('/formqstlang/', param).catch( function (error) {
                console.log(error)
                console.log("N3 - ", response.data);
                if(error.response.data.Message) {
                    // setError(error => [...error,error.response.data.Message]);
                    setFormError(response.data[0].msgRetorno);
                } else {
                    // setError(error => [...error,error.response.data.Message]);
                    setFormError(response.data[0].msgRetorno);
                }
            });
            if(response) {
                // setSuccess(success => [...success,response.data.Message]);
                setFormOk(response.data[0].msgRetorno)
            }

            param = {
                language: 2,
                stringquestions: JSON.stringify(listQuestions)
            }

            response = await api.put('/formqstlang/', param).catch( function (error) {
                console.log(error)
                console.log("N3 - ", response.data);
                if(error.response.data.Message) {
                    // setError(error => [...error,error.response.data.Message]);
                    setFormError(response.data[0].msgRetorno);
                } else {
                    // setError(error => [...error,error.response.data.Message]);
                    setFormError(response.data[0].msgRetorno);
                }
            });
            if(response) {
                // setSuccess(success => [...success,response.data.Message]);
                setFormOk(response.data[0].msgRetorno)
            }
            
            // // =======================================================================
            
            // // Salvamento tipo novos de lista N4 ========================================

            // param = {
            //     stringlisttypes: JSON.stringify(newListType)
            // }

            // response = await api.put('/formqstlisttype/', param).catch( function (error) {
            //     console.log(error)
            //     if(error.response.data.Message) {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     } else {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     }
            // });
            // if(response) {
            //     // setSuccess(success => [...success,response.data.Message]);
            //     setFormOk(response.data[0].msgRetorno)
            // }

            // // =======================================================================

            // Salvamento dos tipo de questoes N5 =======================================
            // updateQstType(listQuestionsTypes); 
            // =======================================================================


            // // Salvamento questoes/novo tipo de lista N6 ================================
            // param = {
            //     stringlisttypes: JSON.stringify(questionListType)
            // }
            // response = await api.put('/formqstlisttypeqst/', param).catch( function (error) {
            //     console.log(error)
            //     if(error.response.data.Message) {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     } else {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     }
            // });
            // if(response) {
            //     // setSuccess(success => [...success,response.data.Message]);
            //     setFormOk(response.data[0].msgRetorno)
            // }
            // // =======================================================================


            // // Salvamento lista de valores respostas de cada tipo de lista N7 ===========
            // param = {
            //     stringlistofvalues: JSON.stringify(answerListType)  
            // }
            // response = await api.put('/formqstlistofvalues/', param).catch( function (error) {
            //     console.log(error)
            //     if(error.response.data.Message) {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     } else {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     }
            // });
            // if(response) {
            //     // setSuccess(success => [...success,response.data.Message]);
            //     setFormOk(response.data[0].msgRetorno)
            // }
            // // =======================================================================


            // // Amarrando os novos tipos de lista com as listas de valoresa N8 ===========
            // param = {
            //     stringlisttypeslistofvalues: JSON.stringify(answerListType2) 
            // }
            // response = await api.put('/formqstlisttypelistofvalues/', param).catch( function (error) {
            //     console.log(error)
            //     if(error.response.data.Message) {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     } else {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     }
            // });
            // if(response) {
            //     // setSuccess(success => [...success,response.data.Message]);
            //     setFormOk(response.data[0].msgRetorno)
            // }
            // // =======================================================================


            // // Salvamento lista de questões subordinadas e subordinantes N9 =============
            // param = {
            //     stringsubordinateto: JSON.stringify(listSubordinate)
            // }
            // response = await api.put('/formqstsubordinateto/', param).catch( function (error) {
            //     console.log(error)
            //     if(error.response.data.Message) {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     } else {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     }
            // });
            // if(response) {
            //     // setSuccess(success => [...success,response.data.Message]);
            //     setFormOk(response.data[0].msgRetorno)
            // }
            // // =======================================================================  
            

            // // Salvamento array com a lista de valores subordinados N10 ==================
            // param = {
            //     stringsubordinatevalues: JSON.stringify(listValueSubordinate)  
            // }
            // response = await api.put('/formqstsubordinatevalues/', param).catch( function (error) {
            //     console.log(error)
            //     if(error.response.data.Message) {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     } else {
            //         // setError(error => [...error,error.response.data.Message]);
            //         setFormError(response.data[0].msgRetorno);
            //     }
            // });
            // if(response) {
            //     // setSuccess(success => [...success,response.data.Message]);
            //     setFormOk(response.data[0].msgRetorno)
            // }
            // // =======================================================================  

        }else{
            setButtonOpen(false);
        }
        console.log("qstsorder", qstsorder);
        console.log("listGroups", listGroups);
        console.log("location.state.questionnaireID", location.state.questionnaireID);
        console.log("listNewOrderQuestions", listNewOrderQuestions);
        console.log("listQuestions", listQuestions);
        console.log("listQuestionsTypes", listQuestionsTypes);
        console.log("listGroupsQuestions", listGroupsQuestions);
        console.log("newListType", newListType);
        console.log("questionListType", questionListType);
        console.log("answerListType", answerListType);
        console.log("answerListType2", answerListType2);
        console.log("listSubordinate", listSubordinate);
        console.log("listValueSubordinate", listValueSubordinate);

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

    const [countLastListTypeId, setCountLastListTypeId] = useState(0);
    const [countLastListOfValuesId, setCountLastListOfValuesId] = useState(0);

    // var countLastListOfValuesId = 0;

    // Função para criar novas perguntas e novos grupos
    async function handleSaveNewQuestion(
        idQuestion, 
        descricaoNovoGrupo,
        descricaoPergunta, 
        selectExistsTypeQuestion,
        tipoQuestao,
        tipoQuestaoDescricao,
        valoresRespostas,
        selectSubordinateQuestion,
        valoresRespostasSubodinacao
    ) {

        let lastGroupId = await api.get('/formgroupid/');
        lastGroupId = parseInt(lastGroupId.data[0].msgRetorno);

        let lastQuestionId = await api.get('/formqstid/');
        lastQuestionId = parseInt(lastQuestionId.data[0].msgRetorno);

        var lastListTypeId = await api.get('/formlisttypeid/');
        lastListTypeId = parseInt(lastListTypeId.data[0].msgRetorno);

        var lastListOfValuesId = await api.get('/formlistofvaluesid/');
        lastListOfValuesId = parseInt(lastListOfValuesId.data[0].msgRetorno);

        let myObj = questions.find(obj => parseInt(obj.qstId) === parseInt(idQuestion));
        let myObjIndex = questions.findIndex(obj => parseInt(obj.qstId) === parseInt(idQuestion));
        console.log("myObjIndex", myObjIndex);

        if(descricaoNovoGrupo){
            var left = questions.slice(0, myObjIndex)
            var right = questions.slice(myObjIndex)
        }else{
            var left = questions.slice(0, (myObjIndex + 1))
            var right = questions.slice((myObjIndex + 1))
        }


        console.log("questions", questions);
        console.log("right", right);

        let objCopy = {...myObj};

        setContI(contI + 1);

        if(descricaoNovoGrupo){
            objCopy.dsc_qst_grp = descricaoNovoGrupo
        }

        objCopy.dsc_qst = descricaoPergunta
        objCopy.qstId = lastQuestionId + contI
        objCopy.qstOrder = ""

        if(selectExistsTypeQuestion){
            objCopy.qst_type = selectExistsTypeQuestion
            if(selectExistsTypeQuestion == "YNU_Question"){
                objCopy.qst_list_type = "ynu_list";
                objCopy.qst_list_type_comment = "Este é um comentário sobre o tipo da lista";
                objCopy.qst_type_id = 8;
                objCopy.rsp_pad = "Não,Desconhecido,Sim";
                objCopy.rsp_padId = "296,297,298";
            }
            if(selectExistsTypeQuestion == "YNUN_Question"){
                objCopy.qst_list_type = "ynun_list";
                objCopy.qst_list_type_comment = "Este é um comentário sobre o tipo da lista";
                objCopy.qst_type_id = 9;
                objCopy.rsp_pad = "Não informado,Não,Desconhecido,Sim";
                objCopy.rsp_padId = "299,300,301,302";
            }
            if(selectExistsTypeQuestion == "Boolean_Question"){
                objCopy.qst_type_id = 1;
            }
            if(selectExistsTypeQuestion == "Date question"){
                objCopy.qst_type_id = 2;
            }
            if(selectExistsTypeQuestion == "Laboratory question"){
                objCopy.qst_type_id = 3;
            }
            if(selectExistsTypeQuestion == "Number question"){
                objCopy.qst_type_id = 5;
            }
            if(selectExistsTypeQuestion == "PNNot_done_Question"){
                objCopy.qst_type_id = 6;
            }
            if(selectExistsTypeQuestion == "Text_Question"){
                objCopy.qst_type_id = 7;
            }
            if(selectExistsTypeQuestion == "Ventilation question"){
                objCopy.qst_type_id = 10;
            }
        }
        if(tipoQuestao){
            // console.log("tipoQuestao", tipoQuestao);
            
            let id_q = {}
            id_q[lastQuestionId + contI] = lastListTypeId + countLastListTypeId
            
            let id_q_desc = {}
            id_q_desc[lastListTypeId + countLastListTypeId] = tipoQuestaoDescricao

            let str = valoresRespostas;
            let str_array_split = str.split(',');
            console.log("str_array_split", str_array_split);
            let idValoresResposta = ""

            str_array_split.forEach((element,index,array )=> {
                console.log("element", element);
                let structTemp = {}
                structTemp[lastListOfValuesId + countLastListOfValuesId + index] = element
                setAnswerListType(answerListType => [...answerListType,structTemp] );

                let structTemp2 = {}
                structTemp2[lastListOfValuesId + countLastListOfValuesId + index] = lastListTypeId + countLastListTypeId
                setAnswerListType2(answerListType2 => [...answerListType2,structTemp2] );

                if(index == 0){
                    idValoresResposta += (lastListOfValuesId + countLastListOfValuesId + index);
                }else{
                    idValoresResposta += ("," + (lastListOfValuesId + countLastListOfValuesId + index));
                }
                if (index === array.length - 1){
                    setCountLastListOfValuesId(countLastListOfValuesId + index + 1);
                }
            });

            setNewListType(newListType => [...newListType,id_q_desc] );
            setQuestionListType(questionListType => [...questionListType,id_q] );

            objCopy.qst_type = tipoQuestao
            objCopy.qst_type_id = 4
            objCopy.qst_type_comment = tipoQuestaoDescricao
            objCopy.rsp_pad = valoresRespostas
            // objCopy.rsp_padId = "Sem id para respostas ainda"
            objCopy.rsp_padId = idValoresResposta
            setCountLastListTypeId(countLastListTypeId + 1);

            // let id_q_listOfValues = {}
            // id_q_listOfValues[idValoresResposta] = tipoQuestaoDescricao
            // setAnswerListType(answerListType => [...answerListType,id_q_listOfValues] );

            // let id_q_listOfValues2 = {}
            // id_q_listOfValues2[idValoresResposta] = lastQuestionId + contI
            // setAnswerListType2(answerListType2 => [...answerListType2,id_q_listOfValues2] );

        }else{
            let id_q = {}
            id_q[lastQuestionId + contI] = null
            setQuestionListType(questionListType => [...questionListType,id_q] );

        }

 
        if(selectSubordinateQuestion){
            let found_sub = questions.find(element => element.qstId === parseInt(selectSubordinateQuestion));
            // console.log("found_sub", found_sub);
            objCopy.sub_qst = found_sub.dsc_qst
            objCopy.sub_qst_values = valoresRespostasSubodinacao
        }else{
            objCopy.sub_qst = ""
            objCopy.sub_qst_values = null
        }

        left.push(objCopy);
        console.log("left", left);
        let mergeArrays = [...left, ...right]
        console.log("mergeArrays", mergeArrays);

        setQuestions(mergeArrays)
    }

    const handleCloseNewQuestion = () => {
        setOpenNewQuestion(false);
    };

    function handleClickNewQuestion(id, descricaoNovoGrupo) {
        setDescricaoNovoGrupoShow(descricaoNovoGrupo)
        setIdQuestion(id);
        setOpenNewQuestion(false);
        setPopupTitle("Adicione uma nova pergunta");
        setPopupBodyText("Configure a sua nova pergunta.");
        setQuestionComment("");
        setQuestionTypeComment("");
        setQuestionListTypeComment("");
        setQuestionGroupComment("");
        setOpenNewQuestion(true);

    }

    // Submit do formulário de criação de novas questões 
    const onSubmit = (event) => {
        console.log("submit - salvamento");
        event.preventDefault(event);
        var descricaoPergunta = event.target.descricaoPergunta.value
        try{
            var descricaoNovoGrupo = event.target.descricaoNovoGrupo.value;
        }catch{
            var descricaoNovoGrupo = null;
        }
        try {
            var selectExistsTypeQuestion = event.target.selectExistsTypeQuestion.value
            var tipoQuestao = null
            var valoresRespostas = null
        } catch (error) {
            var selectExistsTypeQuestion = null
            // var tipoQuestao = event.target.tipoQuestao.value
            var tipoQuestao = "List question";
            var tipoQuestaoDescricao = event.target.tipoQuestao.value;
            var valoresRespostas = event.target.valoresRespostas.value
        }
        try {
            var selectSubordinateQuestion = event.target.selectSubordinateQuestion.value
            var valoresRespostasSubodinacao = event.target.valoresRespostasSubodinacao.value
        } catch (error) {
            var selectSubordinateQuestion = ""
            var valoresRespostasSubodinacao = null
        }
        handleSaveNewQuestion(
            idQuestion, 
            descricaoNovoGrupo,
            descricaoPergunta, 
            selectExistsTypeQuestion,
            tipoQuestao,
            tipoQuestaoDescricao,
            valoresRespostas,
            selectSubordinateQuestion,
            valoresRespostasSubodinacao
        )
        setOpenNewQuestion(false)
    };

    const [descricaoNovoGrupoShow, setDescricaoNovoGrupoShow] = React.useState(false);
    const [newQuestionTypeShow, setnewQuestionTypeShow] = React.useState(false);
    const [existsQuestionTypeShow, setExistsQuestionTypeShow] = React.useState(true);
    const [subordinateQuestionShow, setSubordinateQuestionShow] = React.useState(false);

    const [checkedNewQuestionType, setCheckedNewQuestionType] = React.useState(false);
    const [checkedSubordinateQuestion, setCheckedSubordinateQuestion] = React.useState(false);

    const handleChangeCheckboxQuestionType = (event) => {
        setCheckedNewQuestionType(event.target.checked)
        setnewQuestionTypeShow(event.target.checked);
        setExistsQuestionTypeShow(!event.target.checked);
    }

    const handleChangeCheckboxSubordinateQuestion = (event) => {
        setCheckedSubordinateQuestion(event.target.checked)
        setSubordinateQuestionShow(event.target.checked);
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
                                            <PlusOne className="Icon plusIcon" onClick={() => handleClickNewQuestion(question.qstId, true)}></PlusOne>
                                            {/* <Container onSubmit={onSubmit} optionsSubordinateQuestion={optionsSubordinateQuestion} options={options} idQuestion={question.qstId}/> */}
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
                                    <div className="qst qst2">
                                        <div className="qstBody qstIconArea">
                                            <PlusOne className="Icon plusIcon" onClick={() => handleClickNewQuestion(question.qstId, false)}></PlusOne>
                                            {/* <Container onSubmit={onSubmit} optionsSubordinateQuestion={optionsSubordinateQuestion} options={options} idQuestion={question.qstId}/> */}
                                        </div>
                                    </div>    
                                </div>
                            </div>
                        </>
                    ))}
                    </>
                    <div className="form-submit">
                        { formError?   <FormError formError={formError}></FormError> : ''  } 
                        { formOk?   <FormOk formOk={formOk}></FormOk> : ''  } 
                        {/* <span className="error">{ error }</span>
                        <span className="success">{ success }</span> */}
                        { buttonOpen ? <Button variant="contained" type="submit" color="primary">Salvar</Button> : '' }
                        {/* <Button onClick={handleReorder} type="submit" variant="contained" color="primary">Salvar</Button> */}
                        {/* <Button onClick={handleReorder} variant="contained" color="primary">Salvar</Button> */}
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

                <Dialog key={Math.random()}
                            open={openNewQuestion}
                            onClose={handleCloseNewQuestion}
                            aria-labelledby="alert-dialog-title"
                            aria-describedby="alert-dialog-description"
                            PaperProps={{
                                sx: {
                                  width: '85vw',
                                  maxHeight: 1000
                                }
                              }}
                            >
                            <form onSubmit={onSubmit} className="formNewQuestions" key={Math.random()}>
                                <DialogTitle id="alert-dialog-title">
                                    {descricaoNovoGrupoShow ? (
                                        <p>Adicione um novo grupo com sua primeira pergunta</p>
                                    ):(
                                        popupTitle
                                    )}
                                </DialogTitle>
                                <DialogContent>
                                    <DialogContentText id="alert-dialog-description">
                                        {/* <b><h2>Adicione uma nova pergunta</h2></b> */}
                                        <div className="form-group">

                                            {descricaoNovoGrupoShow && 
                                                <div className="descricaoNovoGrupo">
                                                    <NewInput descriptionInput={"Descrição do Novo Grupo"} id={"descricaoNovoGrupo"}/>
                                                </div>
                                            }
                                            <NewInput descriptionInput={"Descrição da Pergunta"} id={"descricaoPergunta"}/>
                                            {/* <input type="hidden" id={"idQuestion"} value={idQuestion}></input> */}
                                        </div>
                                        <br/>
                                        <div className="TipoQuestao">
                                            <p>Selecione um tipo de questão:</p>
                                            <FormControlLabel
                                                control={
                                                    <Checkbox checked={checkedNewQuestionType} onChange={handleChangeCheckboxQuestionType} id={"checkboxTipoQuestao"} />
                                                }
                                                label="Criar novo tipo de lista"
                                            />
                                            <br/>
                                            {existsQuestionTypeShow &&
                                                <ModelSelectType
                                                    id={"selectExistsTypeQuestion"}
                                                    placeHolder={"Selecione um tipo de questão existente"}
                                                    options={options}
                                                />
                                            }
                                            {newQuestionTypeShow &&
                                                <div className="form-group">
                                                    <NewInput descriptionInput={"Tipo novo de questão"} id={"tipoQuestao"}/>
                                                    <br/>
                                                    <br/>
                                                    <NewInput descriptionInput={"Valores de resposta (Exemplo: sim,não,desconhecido)"} id={"valoresRespostas"}/>
                                                </div>
                                            }
                                        </div>
                                        <br/>
                                        <div className="SubordinacaoQuestao">
                                            <FormControlLabel
                                                control={
                                                    <Checkbox checked={checkedSubordinateQuestion} onChange={handleChangeCheckboxSubordinateQuestion} />
                                                }
                                                label="Adicionar subordinação a essa questão"
                                            />
                                            {subordinateQuestionShow &&
                                                <div className="form-group">
                                                    <ModelSelectType
                                                        id={"selectSubordinateQuestion"}
                                                        placeHolder={"Selecione a questão a qual será subordinada"}
                                                        options={optionsSubordinateQuestion}
                                                    />
                                                    <br/>
                                                    <p>Valores de resposta para subordinação:</p>
                                                    <br/>
                                                    <NewInput descriptionInput={"exemplo1,exemplo2,exemplo3..."} id={"valoresRespostasSubodinacao"}/>
                                                </div>
                                            }
                                        </div>
                                        
                                    </DialogContentText>
                                </DialogContent>
                                <DialogActions>
                                    <div className="form-group">
                                        <Button className="form-group-button" variant="contained" color="primary" type="submit">
                                            Adicionar
                                        </Button>
                                        <Button className="form-group-button" variant="contained" color="danger" onClick={handleCloseNewQuestion}>Fechar</Button>
                                    </div>
                                </DialogActions>
                            </form>
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