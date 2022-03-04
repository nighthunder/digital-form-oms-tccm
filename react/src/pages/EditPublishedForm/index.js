// View do formulário quando é preenchido.
import React, { useState, useEffect, useRef  } from 'react';
import './styles.css';
import { useLocation } from "react-router-dom";
import { Scrollchor } from 'react-scrollchor';
import { TextField, Button, FormLabel, RadioGroup, Radio, FormControlLabel, InputLabel, Select, MenuItem } from '@material-ui/core';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpwardRounded';
import InfoIcon from '@mui/icons-material/InfoRounded';
import { makeStyles } from '@material-ui/styles';
import api from '../../services/api';
import { connect } from 'react-redux';
import { useHistory } from "react-router-dom";
import validFormDate from '../../utils/methods/validFormDate';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';

const useStyles = makeStyles({
    root: {
      '& input': {
          fontSize: '0.75rem',
      }
    },
});

function EditPublishedForm({logged, user, participantId}) {

    const location = useLocation();  
    const classes = useStyles();
    //console.log("Location Formulario", location);
    const sim = useRef();
    const titles = ['Admissão','Acompanhamento','Desfecho']
    const [form, setForm] = useState({});
    const [formError, setFormError] = useState('')
    const history = useHistory();
    const [questions, setQuestions] = useState([]);
    const [questionstype, setQuestionsType] = useState([]);
    const [loadedResponses, setLoadedResponses] = useState(false);
    const [hospitalName, setHospitalName] = useState('');

    // popup
    const [popupTitle, setPopupTitle] = useState('');
    const [popupBodyText, setPopupBodyText] = useState([]);

    useEffect(() => {
        async function loadForm() {
            const response = await api.get('/form/' + location.state.modulo);
            setQuestions(response.data);

            //console.log("QUESTOES", questions);
            //console.log("formRecordId", location.state.formRecordId);

            // Caso seja uma atualização de formulário
            if(location.state.formRecordId) {
                getRecordedResponses(location.state.formRecordId)
            }
        }
        loadForm();
        setHospitalName(user[location.state.hospitalIndex].hospitalName);

        async function loadQuestionTypeAltText() {
            const response = await api.get('/questiontype/' + location.state.modulo);
            setQuestionsType(response.data);    

        }
        loadQuestionTypeAltText();
    }, [])

    async function getRecordedResponses(formRecordId) {
        const response = await api.get(`/formResponses/${formRecordId}`);
        console.log('RESPOSTAS', response.data);
        if(response.data) {
            fillForm(response.data);
        }
    }

    function fillForm(responses) {
        let formWithResponse = { }
        for(let response of responses) {
            if(response.answer != null) {
                if(response.rsp_listofvalue)
                    formWithResponse[response.qstId] = response.rsp_listofvalue
                else
                    formWithResponse[response.qstId] = response.answer
            }
        }

        setForm(formWithResponse);
        console.log("FORM AQUI", form);
        setLoadedResponses(true)
    }

    function getCurrentDate() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear();

        return yyyy + '-' + mm + '-' + dd;
    }

    function handleChange(e) {
        const target = e.target;
        const value = target.value;
        const name = target.name;

        //console.log('idQuestão: ' + target.name, 'value: ' + target.value);

        if(target.name == getIdFromDateQuestion() && formError)
            setFormError('')

        setForm({
            ...form,
            [name]: value,
        });

        console.log("form", form);

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

    function getIdFromDateQuestion() {
        switch (location.state.modulo) {
            case 1:
                return 167
            case 2:
                return 168
            case 3:
                return 124
            
        }
    }

    // popup
    const [open, setOpen] = React.useState(false);
    const handleClickOpen = () => {
        setOpen(false);
        setPopupTitle("Informações extras");
        setPopupBodyText(questionstype);
        setOpen(true);
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


    async function submit(e) {
        e.preventDefault();
        console.log(form);

        let request;
        let dateQuestionId = getIdFromDateQuestion();
        let response;

        let validationDate = validFormDate(location.state.registeredModules, location.state.modulo, form[dateQuestionId], location.state.formRecordId ? true : false)
        console.log(validationDate);

        if(!validationDate.isValid) {
            setFormError(validationDate.message);
            return;
        }

        // Caso seja uma atualização de formulário
        if(location.state.formRecordId) {
            console.log('ATUALIZAÇÃO DO FORM ', location.state.formRecordId);

            request = {
                respostas: JSON.stringify(form),
                info: user[location.state.hospitalIndex],
                participantId: participantId,
                dataAcompanhamento: form[dateQuestionId],
                modulo: location.state.modulo,
                formRecordId: location.state.formRecordId
            }


            console.log( [ request.info['userid'], request.info['grouproleid'], request.info['hospitalunitid'], request.participantId, 1, request.modulo, request.formRecordId, request.respostas ]);

            response = await api.put('/form/' + location.state.modulo, request);
            
        } else { // Caso seja um novo formulário
            request = {
                respostas: JSON.stringify(form),
                info: user[location.state.hospitalIndex],
                participantId: participantId,
                dataAcompanhamento: form[dateQuestionId],
                modulo: location.state.modulo
            }
    
            response = await api.post('/form/' + location.state.modulo, request);
        }

        console.log('response',response);

        if(location.state.formRecordId)
            history.go(-1);
        else
            history.go(-2);
    }

    function handleBackButton(){
        history.goBack();
    }

    function handleSimYNUN(e){
        console.log("EXECUTEI");
    }

    return (
        <main className="container">
            <div>
                <header className="index ">
                    { hospitalName } > <b>{ titles[location.state.modulo-1] }</b>
                </header>
                <div className="mainNav">
				    <h2 className="pageTitle">Módulo { location.state.modulo } - { titles[location.state.modulo-1] } - {location.state.moduleStatus} [Edição]</h2>
                    <ArrowBackIcon className="ArrowBack" onClick={handleBackButton}/>
                    <Scrollchor to="#vodan_br"><ArrowUpwardIcon className="ArrowUp" /></Scrollchor>
                </div>
                 <p className="questionnaireDesc"> Questionário: {location.state.questionnaireDesc} ( {location.state.questionnaireVers} ) {location.state.questionnaireStatus}  </p>
                 <InfoIcon className="ArrowInfo" onClick={handleClickOpen}/>
                <form className="module" onSubmit={submit}>
                    <div>
                    { questions.length === 0 && (location.state.formRecordId ? !loadedResponses : true) &&
                        <div className="loading">
                            <img src="assets/loading.svg" alt="Carregando"/>
                        </div>
                    }
                    {
                        console.log("QUESTIONS2", questions)
                    }
                    {questions.map((question, index) => (
                        <div className="qst qst2" key={question.qstId}>
                            {/* Se for um novo grupo de questões*/}
                            { (question.dsc_qst_grp !== ""  && checkTitle(index, question)) &&
                            <div className="groupHeader" id={question.qstId}>
                               <TextField className="inputQst" name={String(question.qstId)} value={question.dsc_qst_grp}>{question.dsc_qst_grp}</TextField>
                                <p className="questionType groupType">Grupo de questões</p>
                            </div>
                            }
                            <div className="qstBody">
                            
                            {/* Se for do tipo Date question*/}
                            { (question.qst_type === "Date question") && 
                            <div>
                                <InputLabel className="qstLabel">Questão</InputLabel>
                                <TextField className={classes.root} className="inputQst inputQst2" name={String(question.qstId)} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } fullWidth multiline>{question.dsc_qst}</TextField>
                                <p className="questionType">Tipo da questão: {question.qst_type}</p>
                                { question.sub_qst !== '' &&
                                 <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                                }
                            </div>
                            }

                            {/* Se for do tipo Number question*/}
                            { (question.qst_type === "Number question") && 
                            <div>
                            {/*<TextField  type="number" name={String(question.qstId)} label={question.dsc_qst} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } />*/}
                            <InputLabel>Questão:</InputLabel>
                            <TextField className="inputQst inputQst2" value={form[question.qstId] ? form[question.qstId] : question.dsc_qst }  fullWidth multiline>{question.dsc_qst}</TextField>
                            <p className="questionType">Tipo da questão: {question.qst_type}</p>
                            { question.sub_qst !== '' &&
                               <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                            }
                            </div>
                            }

                            {/* Se for do tipo List question ou YNU_Question ou YNUN_Question e tenha menos de 6 opções */}
                            { (question.qst_type === "List question" || question.qst_type === "YNU_Question" || question.qst_type === "YNUN_Question") && ( (question.rsp_pad.split(',')).length < 6 ) &&
                            <div className="MuiTextField-root  MuiTextField-root2 MuiForm">
                                <InputLabel>Questão:</InputLabel>
                                <TextField  className="inputQst inputQst2" onChange={handleChange} name={String(question.qstId)} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst }  fullWidth multiline>{question.dsc_qst}</TextField>
                                <p className="questionType">Tipo da questão: {question.qst_type}</p>
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
                                <InputLabel>Questão:</InputLabel>
                                <TextField  className="inputQst inputQst2" onChange={handleChange} name={String(question.qstId)} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst }  fullWidth multiline>{question.dsc_qst}</TextField>
                                <p className="questionType">Tipo da questão: {question.qst_type}</p>
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
                            <InputLabel>Questão:</InputLabel>
                            <TextField  className="inputQst inputQst2" name={String(question.qstId)} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } fullWidth multiline>{question.dsc_qst}</TextField>
                            <p className="questionType">Tipo da questão: {question.qst_type}</p>
                            { question.sub_qst !== '' &&
                               <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                            }
                            </div>
                            }

                            {/* Se for do tipo Boolean_Question*/}
                            { (question.qst_type === "Boolean_Question") && 
                            <div className="MuiTextField-root  MuiTextField-root2 MuiForm">
                                <InputLabel>Questão:</InputLabel>
                                <TextField  className="inputQst inputQst2" name={String(question.qstId)} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } fullWidth multiline>{question.dsc_qst}</TextField>
                                <p className="questionType">Tipo da questão: {question.qst_type}</p>
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
                    ))}
                    </div>
                    <div className="form-submit">
                        <p className="error"> { formError } </p>
                        <Button variant="contained" type="submit" color="primary">Salvar</Button>
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
                                {popupBodyText.map((questiontype, index) => (
                                    <div>{questiontype.description} - {questiontype.altText}<br/></div>
                                )) } 
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
export default connect(state => ({ logged: state.logged, user:state.user, participantId: state.participantId }))(EditPublishedForm);