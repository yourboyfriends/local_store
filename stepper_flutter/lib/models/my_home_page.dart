import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stepper_flutter/models/address_Info.dart';
import 'district.dart';
import 'province.dart';
import 'user_Info.dart';
import 'ward.dart';
import 'package:intl/intl.dart';
import 'package:diacritic/diacritic.dart';
import 'package:localstore/localstore.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();

  UserInfo userInfo = UserInfo();
  bool isLoaded = false;
  int activeStepIndex = 0;

  Future<UserInfo> init() async {
    if (isLoaded) return userInfo;
    var value = await loadUserInfo();
    if (value != null) {
      try {
        isLoaded = true;
        return UserInfo.fromMap(value);
      } catch (e) {
        debugPrint(e.toString());
        return UserInfo();
      }
    }

    return UserInfo();
  }

  @override
  Widget build(BuildContext context) {
    void updateStep(int value) {
      if (activeStepIndex == 0) {
        if (step1FormKey.currentState!.validate()) {
          step1FormKey.currentState!.save();
          setState(() {
            activeStepIndex = value;
          });
        }
      } else if (activeStepIndex == 1) {
        if (value > activeStepIndex) {
          if (step2FormKey.currentState!.validate()) {
            step2FormKey.currentState!.save();
            setState(() {
              activeStepIndex = value;
            });
          }
        } else {
          setState(() {
            activeStepIndex = value;
          });
        }
      } else if (activeStepIndex == 2) {
        setState(() {
          if (value < activeStepIndex) {
            activeStepIndex = value;
          } else {
            saveUserInfo(userInfo).then((value) {
              showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Thông báo'),
                      content: const SingleChildScrollView(
                        child: ListBody(
                          children: [
                            Text('Hồ sơ người dùng đã được lưu thành công'),
                            Text('Bạn có thể quay lại bước cập nhật'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Đóng'),
                        )
                      ],
                    );
                  });
            });
          }
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhận hồ sơ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text('Bạn có muốn xóa thông tin đã lưu?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Hủy'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Đồng ý'),
                      ),
                    ],
                  );
                },
              ).then((value) {
                if (value != null && value == true) {
                  setState(() {
                    userInfo = UserInfo();
                  });
                  saveUserInfo(userInfo);
                }
              });
            },
            icon: const Icon(Icons.delete_outlined),
          )
        ],
      ),
      body: FutureBuilder<UserInfo>(
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            userInfo = snapshot.data!;
            return Stepper(
              type: StepperType.horizontal,
              currentStep: activeStepIndex,
              controlsBuilder: (context, details) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      children: [
                        if (activeStepIndex == 2)
                          FilledButton(
                            onPressed: details.onStepContinue,
                            child: const Text('Lưu'),
                          )
                        else
                          FilledButton.tonal(
                            onPressed: details.onStepContinue,
                            child: const Text('Tiếp'),
                          ),
                        if (activeStepIndex > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Quay lại'),
                          ),
                      ],
                    ),
                    if (activeStepIndex == 2)
                      OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Đóng'),
                      )
                  ],
                );
              },
              onStepTapped: (value) {
                updateStep(value);
              },
              onStepCancel: () {
                if (activeStepIndex > 0) {
                  setState(() {
                    activeStepIndex--;
                  });
                }
              },
              onStepContinue: () {
                updateStep(activeStepIndex + 1);
              },
              steps: [
                Step(
                  title: const Text('Cơ bản'),
                  content: Step1Form(formKey: step1FormKey, userInfo: userInfo),
                  isActive: activeStepIndex == 0,
                ),
                Step(
                  title: const Text('Địa chỉ'),
                  content: Step2Form(formKey: step2FormKey, userInfo: userInfo),
                  isActive: activeStepIndex == 1,
                ),
                Step(
                  title: const Text('Xác nhận'),
                  content: ConfirmInfo(userInfo: userInfo),
                  isActive: activeStepIndex == 2,
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Lỗi: ${snapshot.error}"),
            );
          } else {
            return const Center(child: LinearProgressIndicator());
          }
        },
      ),
    );
  }
}

class Step1Form extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final UserInfo userInfo;
  const Step1Form({super.key, required this.formKey, required this.userInfo});

  @override
  State<Step1Form> createState() => _Step1FormState();
}

class _Step1FormState extends State<Step1Form> {
  final namectl = TextEditingController();
  final datectl = TextEditingController();
  final emailctl = TextEditingController();
  final phonectl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    namectl.text = widget.userInfo.name ?? '';
    datectl.text = widget.userInfo.birthDate != null
        ? DateFormat('dd/MM/yyyy').format(widget.userInfo.birthDate!)
        : '';
    emailctl.text = widget.userInfo.email ?? '';
    phonectl.text = widget.userInfo.phoneNumber ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Form(
          key: widget.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: namectl,
                decoration: const InputDecoration(labelText: 'Họ và tên :'),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui loàng nhập tên';
                  }
                  return null;
                },
                onChanged: (value) {
                  widget.userInfo.name = value;
                },
              ),
              TextFormField(
                controller: datectl,
                decoration: const InputDecoration(
                  labelText: 'Ngày sinh :',
                  hintText: 'Nhập ngày sinh',
                ),
                onTap: () async {
                  DateTime? date = DateTime(1900);
                  FocusScope.of(context).requestFocus(FocusNode());
                  date = await showDatePicker(
                      context: context,
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                      initialDate: widget.userInfo.birthDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100));
                  if (date != null) {
                    widget.userInfo.birthDate = date;
                    datectl.text = DateFormat('dd/MM/yyy').format(date);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui loàng nhập ngày sinh';
                  }
                  try {
                    DateFormat('dd/MM/yyyy').parse(value);
                    return null;
                  } catch (e) {
                    return 'Ngày sinh không hợp lệ';
                  }
                },
              ),
              TextFormField(
                controller: emailctl,
                decoration: const InputDecoration(labelText: 'Email :'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui loàng nhập email';
                  }
                  return null;
                },
                onChanged: (value) => widget.userInfo.email = value,
              ),
              TextFormField(
                controller: phonectl,
                decoration: const InputDecoration(labelText: 'Số điện thoại :'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui loàng nhập số điện thoại';
                  }
                  return null;
                },
                onChanged: (value) => widget.userInfo.phoneNumber = value,
              ),
            ],
          )),
    );
  }
}

class Step2Form extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final UserInfo userInfo;
  const Step2Form({super.key, required this.formKey, required this.userInfo});

  @override
  State<Step2Form> createState() => _Step2FormState();
}

class _Step2FormState extends State<Step2Form> {
  final streetctl = TextEditingController();

  List<Province> provinceList = [];
  List<District> districtList = [];
  List<Ward> wardList = [];

  @override
  void initState() {
    loadLocationData().then((value) => setState(() {}));
    super.initState();
  }

  Future<void> loadLocationData() async {
    try {
      String data =
          await rootBundle.loadString('assets/don_vi_hanh_chinh.json');
      Map<String, dynamic> jsonData = json.decode(data);
      List provinceData = jsonData['province'];
      provinceList =
          provinceData.map((json) => Province.fromMap(json)).toList();
      List districtData = jsonData['district'];
      districtList =
          districtData.map((json) => District.fromMap(json)).toList();
      List wardData = jsonData['ward'];
      wardList = wardData.map((json) => Ward.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Error loading location data $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    streetctl.text = widget.userInfo.address?.street ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Form(
          key: widget.formKey,
          child: Column(
            children: [
              Autocomplete<Province>(
                fieldViewBuilder: (
                  context,
                  textEditingController,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    textEditingController.text =
                        widget.userInfo.address?.province?.name ?? '';
                  });
                  return TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Tỉnh / Thành phố',
                    ),
                    onTap: () {
                      debugPrint(provinceList.toString());
                    },
                    controller: textEditingController,
                    focusNode: focusNode,
                    validator: (value) {
                      if (widget.userInfo.address?.province == null ||
                          value!.isEmpty) {
                        return 'Vui lòng chọn một Tỉnh /  Thành phố';
                      }
                      return null;
                    },
                  );
                },
                displayStringForOption: (option) => option.name!,
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return provinceList;
                  }
                  return provinceList.where((element) {
                    final title = removeDiacritics(element.name ?? '');
                    final keyword = removeDiacritics(textEditingValue.text);
                    final partern = r'\b(' + keyword + r')\b';
                    final regExp = RegExp(partern, caseSensitive: false);
                    return title.isNotEmpty && regExp.hasMatch(title);
                  });
                },
                onSelected: (option) {
                  if (widget.userInfo.address?.province != option) {
                    setState(() {
                      widget.userInfo.address = AddressInfo(province: option);
                    });
                  }
                },
              ),
              Autocomplete<District>(
                fieldViewBuilder: (
                  context,
                  textEditingController,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    textEditingController.text =
                        widget.userInfo.address?.district?.name ?? '';
                  });
                  return TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Huyện / Quận',
                    ),
                    onTap: () {
                      debugPrint(districtList.toString());
                    },
                    controller: textEditingController,
                    focusNode: focusNode,
                    validator: (value) {
                      if (widget.userInfo.address?.district == null ||
                          value!.isEmpty) {
                        return 'Vui lòng chọn một Huyện /  Quận';
                      }
                      return null;
                    },
                  );
                },
                displayStringForOption: (option) => option.name!,
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return districtList.where((element) =>
                        widget.userInfo.address?.province?.id != null &&
                        element.provinceId ==
                            widget.userInfo.address?.province?.id);
                  }
                  return districtList.where((element) {
                    var cond1 = element.provinceId ==
                        widget.userInfo.address?.province?.id;
                    final title = removeDiacritics(element.name ?? '');
                    final keyword = removeDiacritics(textEditingValue.text);
                    final partern = r'\b(' + keyword + r')\b';
                    final regExp = RegExp(partern, caseSensitive: false);
                    return cond1 && title.isNotEmpty && regExp.hasMatch(title);
                  });
                },
                onSelected: (option) {
                  if (widget.userInfo.address?.district != option) {
                    setState(() {
                      widget.userInfo.address?.district = option;
                      widget.userInfo.address?.ward = null;
                    });
                  }
                },
              ),
              Autocomplete<Ward>(
                fieldViewBuilder: (
                  context,
                  textEditingController,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    textEditingController.text =
                        widget.userInfo.address?.ward?.name ?? '';
                  });
                  return TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Xã / Phường / Thị trấn',
                    ),
                    onTap: () {
                      debugPrint(wardList.toString());
                    },
                    controller: textEditingController,
                    focusNode: focusNode,
                    validator: (value) {
                      if (widget.userInfo.address?.ward == null ||
                          value!.isEmpty) {
                        return 'Vui lòng chọn một Xã /  Phường / Thị trấn';
                      }
                      return null;
                    },
                  );
                },
                displayStringForOption: (option) => option.name!,
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return wardList.where((element) =>
                        element.districtId ==
                        widget.userInfo.address?.district?.id);
                  }
                  return wardList.where((element) {
                    var cond1 = element.districtId ==
                        widget.userInfo.address?.district?.id;
                    final title = removeDiacritics(element.name ?? '');
                    final keyword = removeDiacritics(textEditingValue.text);
                    final partern = r'\b(' + keyword + r')\b';
                    final regExp = RegExp(partern, caseSensitive: false);
                    return cond1 && title.isNotEmpty && regExp.hasMatch(title);
                  });
                },
                onSelected: (option) {
                  widget.userInfo.address?.ward = option;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ chi tiết',
                ),
                keyboardType: TextInputType.streetAddress,
                controller: streetctl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
                onSaved: (value) {
                  widget.userInfo.address?.street = value!;
                },
              )
            ],
          )),
    );
  }
}

class ConfirmInfo extends StatelessWidget {
  final UserInfo userInfo;
  const ConfirmInfo({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildInfoItem('Họ và tên :', userInfo.name),
        _buildInfoItem(
            'Ngày sinh :',
            userInfo.birthDate != null
                ? DateFormat('dd/MM/yyyy').format(userInfo.birthDate!)
                : ''),
        _buildInfoItem('Email :', userInfo.email),
        _buildInfoItem('Số điện thoại :', userInfo.phoneNumber),
        _buildInfoItem('Tỉng / Thành phố :', userInfo.address?.province?.name),
        _buildInfoItem('Huyện / Quận :', userInfo.address?.district?.name),
        _buildInfoItem(
            'Xã / Phường / Thị trấn :', userInfo.address?.ward?.name),
        _buildInfoItem('Địa chỉ chi tiết :', userInfo.address?.street),
      ]),
    );
  }

  Widget _buildInfoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(8.0),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

Future<void> saveUserInfo(UserInfo info) async {
  return await Localstore.instance
      .collection('users')
      .doc('info')
      .set(info.toMap());
}

Future<Map<String, dynamic>?> loadUserInfo() async {
  return await Localstore.instance.collection('users').doc('info').get();
}
