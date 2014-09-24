// set up some iterators for the different components
workflow._iterator = {};
workflow._iterator.job = 0;
workflow._iterator.jobstep = 0;

// set up helpers for jobs
workflow.nextJob = function() {
    if(!this.jobs) return null;
    if(workflow._iterator.job == this.jobs.length) {
        workflow._iterator.job = 0;
        return null;
    }
    return this.job[this.jobs[workflow._iterator.job++]];
};
workflow.hasMoreJobs = function() {
    if(!this.jobs) return false;
    return workflow._iterator.job < this.jobs.length;
};
workflow.isFirstJob = function() {
    return workflow._iterator.job == 1;
};

var job;
while(job = workflow.nextJob()) {
    job.nextStep = function() {
        if(!this.jobsteps) return null;
        if(workflow._iterator.jobstep == this.jobsteps.length) {
            workflow._iterator.jobstep = 0;
            return null;
        }
        return this.jobstep[this.jobsteps[workflow._iterator.jobstep++]];
    };
    job.hasMoreSteps = function() {
        if(!this.jobsteps) return false;
        return workflow._iterator.jobstep < this.jobsteps.length;
    };
    job.isFirstStep = function() {
        return workflow._iterator.jobstep == 1;
    };
}


