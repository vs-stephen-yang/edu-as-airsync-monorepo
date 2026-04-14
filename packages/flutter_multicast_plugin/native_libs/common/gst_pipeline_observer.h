#pragma once

class GstPipelineObserver {
  public:
    virtual void on_pipeline_error() = 0;
    virtual ~GstPipelineObserver() {}
};
