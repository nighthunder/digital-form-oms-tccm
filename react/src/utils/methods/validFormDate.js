import { DateTime, Interval } from 'luxon';


/* 
    A admissão não deve ser aceita caso:
    - Tenha uma admissão aberta sem desfecho
    - Caso a data da admissão seja anterior ao último desfecho
*/
function validAdmission(modules, newModuleDate, isEditing) {
    if(modules.length === 0)
        return  { isValid: true, message: '' }
    
    let numberOfAdmissions = 0;
    let numberOfReleases = 0;
    let lastReleaseDate;

    for(module of modules) {
        if(module.crfformsid === 1)
            numberOfAdmissions++
        if(module.crfformsid === 3) {
            numberOfReleases++
            lastReleaseDate = module.dataRefer;
        }    
    }

    if(numberOfAdmissions > numberOfReleases) {
        return { isValid: false, message: 'Data Inválida. Não é possivel adicionar uma admissão sem que a última tenha sido fechada.' }
    }

    lastReleaseDate = DateTime.fromISO(lastReleaseDate.toISOString())
    let today = DateTime.local(); 
    let moduleDate = DateTime.fromISO(newModuleDate)
    let interval = Interval.fromDateTimes(lastReleaseDate, today);

    if(!interval.contains(moduleDate)) {
        return { isValid: false, message: 'Data Inválida. A data de uma nova admissão deve ser posterior à alta do paciente.'}
    }

    return { isValid: true, message: '' }
}

/*
    O acompanhamento não deve ser aceito caso:
    - Não esteja no intervalo entre uma admissão e um desfecho e não tenha nenhuma admissão em aberto
*/
function validFollowup(modules, newModuleDate, isEditing) {
    if(modules.length === 0)
        return  { isValid: false, message: 'É necessário ter uma admissão anteriormente ao acompanhamento.' }

    let interval
    let isInInterval = false;
    let moduleDate = DateTime.fromISO(newModuleDate)
    let startInterval
    let endInterval

    for(module of modules) {
        if(module.crfformsid === 1)
            startInterval = DateTime.fromISO(module.dataRefer.toISOString())
        if(module.crfformsid === 3) {
            endInterval = DateTime.fromISO(module.dataRefer.toISOString())
            interval = Interval.fromDateTimes(startInterval, endInterval)
            console.log(interval)
            if(interval.contains(moduleDate)) {
                isInInterval = true
                return { isValid: true, message: '' } 
            } else {
                startInterval = null
                endInterval = null
            }
        }
    }

    if(!isInInterval && startInterval && !endInterval) {
        let today = DateTime.local()
        if(Interval.fromDateTimes(startInterval, today).contains(moduleDate))
            return { isValid: true, message: '' }
    }

    if(!isInInterval) {
        return { isValid: false, message: 'O formulário de acompanhamento deve estar numa data entre a admissão e o desfecho, ou após a admissão caso o paciente ainda esteja em acompanhamento.' }
    }
}

function validOutcome(modules, newModuleDate, isEditing) {
    if(modules.length === 0)
        return  { isValid: false, message: 'É necessário ter uma admissão anterior ao desfecho.' }
    
    let today = DateTime.local()
    let moduleDate = DateTime.fromISO(newModuleDate)
    let lastRecordedDate = DateTime.fromISO(modules[modules.length - 1].dataRefer.toISOString())
    let interval = Interval.fromDateTimes(lastRecordedDate, today)

    if(modules[modules.length - 1].crfformsid == 3)
        return { isValid: false, message: 'Não é possível adicionar um desfecho sem que tenha uma admissão.' }

    if(!interval.contains(moduleDate))
        return { isValid: false, message: 'A data de desfecho deve ser após a admissão e os acompanhamentos.' }

    return { isValid: true, message: '' }
}

function validFormDate(modules, newIdModule, newModuleDate, isEditing) {
    let response = {
        isValid: true,
        message: ''
    };

    if(!newModuleDate)
        return { isValid: false, message: 'É necessário inserir a data.'}

    let today = DateTime.local()
    let startDate = DateTime.fromISO("2020-01-01T00:00:00")
    let moduleDate = DateTime.fromISO(newModuleDate)
    let possibleInterval = Interval.fromDateTimes(startDate, today)

    if(!possibleInterval.contains(moduleDate))
        return { isValid: false, message: 'A data deve estar no intervalo de 01-01-2020 até hoje.'}

    console.log('VALIDFORMDATE', modules, newIdModule, newModuleDate, isEditing);
    if(newIdModule === 1) 
        response = validAdmission(modules, newModuleDate, isEditing)
    if(newIdModule === 2) 
        response = validFollowup(modules, newModuleDate, isEditing)
    if(newIdModule === 3) 
        response = validOutcome(modules, newModuleDate, isEditing)

    return response;
}

export default validFormDate;