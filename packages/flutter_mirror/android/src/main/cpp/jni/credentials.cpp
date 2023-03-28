#include "jni/credentials.h"
#include <assert.h>
#include "util/jni/byte_array.h"

#define DEFINE_FIELD(NAME, SIG) \
  NAME##Id = env_->GetFieldID(cls, #NAME, SIG);

namespace jni {

Credentials::Credentials(
    JNIEnv* env,
    jobject obj)
    : env_(env),
      obj_(obj) {
  assert(env);
  assert(obj);

  InitFields();
}

void Credentials::InitFields() {
  jclass cls = env_->GetObjectClass(obj_);

  assert(cls);

  DEFINE_FIELD(year, "I");
  DEFINE_FIELD(month, "I");
  DEFINE_FIELD(day, "I");

  DEFINE_FIELD(deviceCertDer, "[B");
  DEFINE_FIELD(icaCertDer, "[B");

  DEFINE_FIELD(tlsCertDer, "[B");
  DEFINE_FIELD(tlsKeyDer, "[B");

  DEFINE_FIELD(signature, "[B");
}

std::string Credentials::GetBaField(jfieldID fid) const {
  jbyteArray ba = static_cast<jbyteArray>(
      env_->GetObjectField(obj_, fid));

  assert(ba);

  return jni::ByteArray::ToString(env_, ba);
}

jint Credentials::GetIntField(jfieldID fid) const {
  return env_->GetIntField(obj_, fid);
}

openscreen::cast::CastReceiver::Credentials Credentials::FromJObject() const {
  openscreen::cast::CastReceiver::Credentials creds;

  creds.year = GetIntField(yearId);
  creds.month = GetIntField(monthId);
  creds.day = GetIntField(dayId);

  creds.device_cert_der = GetBaField(deviceCertDerId);
  creds.ica_cert_der = GetBaField(icaCertDerId);

  creds.tls_cert_der = GetBaField(tlsCertDerId);
  creds.tls_key_der = GetBaField(tlsKeyDerId);

  creds.signature = GetBaField(signatureId);

  return creds;
}

}  // namespace jni
